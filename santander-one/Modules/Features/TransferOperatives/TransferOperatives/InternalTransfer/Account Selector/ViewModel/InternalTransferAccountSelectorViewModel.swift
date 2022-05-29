//
//  InternalTransferAccountSelectorViewModel.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum InternalTransferAccountSelectorState: State {
    case idle
    case loaded((visible: [AccountRepresentable],
                 notVisible: [AccountRepresentable],
                 selected: AccountRepresentable?,
                 filtered: Bool))
}

final class InternalTransferAccountSelectorViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferAccountSelectorDependenciesResolver
    private let stateSubject = CurrentValueSubject<InternalTransferAccountSelectorState, Never>(.idle)
    var state: AnyPublisher<InternalTransferAccountSelectorState, Never>
    @BindingOptional var operativeData: InternalTransferOperativeData!
    
    init(dependencies: InternalTransferAccountSelectorDependenciesResolver) {
        self.dependencies = dependencies
        self.state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        filterInternalTransferOperativeData()
        trackScreen()
    }
    
    func didSelect(account: AccountRepresentable) {
        resetAmountIfNeededForSelectedAccount(account)
        operativeData.originAccount = account
        dataBinding.set(operativeData)
        next()
    }

    func resetAmountIfNeededForSelectedAccount(_ account: AccountRepresentable) {
        guard let newCurrencyType = account.currencyRepresentable?.currencyType,
              let previousCurrencyType = operativeData.originAccount?.currencyRepresentable?.currencyType else { return }
        if newCurrencyType != previousCurrencyType {
            operativeData.amount = nil
            operativeData.receiveAmount = nil
        }
    }
    
    func didShowHiddenAccounts() {
        trackEvent(.viewHiddenAccounts)
    }
    
    func next() {
        coordinator.next()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions
private extension InternalTransferAccountSelectorViewModel {
    func filterInternalTransferOperativeData() {
        let input = GetInternalTransferOriginAccountsUseCaseInput(
            visibleAccounts: operativeData.originAccountsVisibles,
            notVisibleAccounts: operativeData.originAccountsNotVisibles
        )
        return getInternalTransferOriginAccountsUseCase
            .filterAccounts(input: input)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
            .sink { [weak self] output in
                guard let self = self else { return }
                self.publishAccountsSelectionItems(output: output)
            }
            .store(in: &anySubscriptions)
    }
}

private extension InternalTransferAccountSelectorViewModel {
    func publishAccountsSelectionItems(output: GetInternalTransferOriginAccountsFilteredUseCaseOutput) {
        let totalItems = output.visiblesFiltered.count + output.notVisiblesFiltered.count
        let hasFilteredAcccount = (operativeData.originAccountsVisibles.count + operativeData.originAccountsNotVisibles.count) > totalItems
        stateSubject.send(.loaded((output.visiblesFiltered, output.notVisiblesFiltered, operativeData.originAccount , hasFilteredAcccount)))
    }
}

private extension InternalTransferAccountSelectorViewModel {
    var getInternalTransferOriginAccountsUseCase: GetInternalTransferOriginAccountsFilteredUseCase {
        return dependencies.external.resolve()
    }
    
    var coordinator: InternalTransferOperativeCoordinator {
        return dependencies.resolve()
    }
}

// MARK: Analytics
extension InternalTransferAccountSelectorViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: InternalTransferAccountSelectorPage {
        InternalTransferAccountSelectorPage()
    }
}
