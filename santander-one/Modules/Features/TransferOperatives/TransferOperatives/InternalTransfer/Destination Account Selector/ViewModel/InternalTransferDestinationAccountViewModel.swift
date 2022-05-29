//
//  InternalTransferDestinationAccountViewModel.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 15/2/22.
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum InternalTransferDestinationAccountState: State {
    case idle
    case loaded(InternalTransferLoadedData)
}

struct InternalTransferLoadedData {
    let originAccount: AccountRepresentable
    let visibleAccounts: [AccountRepresentable]
    let notVisibleAccounts: [AccountRepresentable]
    let selectedAccount: AccountRepresentable?
    let showFilteredAccountsMessage: Bool
}

final class InternalTransferDestinationAccountViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferDestinationAccountDependenciesResolver
    private let stateSubject = CurrentValueSubject<InternalTransferDestinationAccountState, Never>(.idle)
    var state: AnyPublisher<InternalTransferDestinationAccountState, Never>
    @BindingOptional var operativeData: InternalTransferOperativeData!
    
    init(dependencies: InternalTransferDestinationAccountDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeDestinationAccounts()
        trackScreen()
    }

    func didSelect(account: AccountRepresentable) {
        operativeData.destinationAccount = account
        dataBinding.set(operativeData)
        next()
    }

    func didChangeAccount() {
        trackEvent(.changeAccount)
    }

    func next() {
        coordinator.next()
    }

    func back() {
        coordinator.back()
    }

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension InternalTransferDestinationAccountViewModel {
    var getDestinationAccounts: GetInternalTransferDestinationAccountsUseCase {
        return dependencies.external.resolve()
    }
    
    var coordinator: InternalTransferOperativeCoordinator {
        return dependencies.resolve()
    }
    
    func subscribeDestinationAccounts() {
        guard let originAccount = operativeData.originAccount else { return }
        let input = GetInternalTransferDestinationAccountsInput(visibleAccounts: operativeData.destinationAccountsVisibles,
                                                                notVisibleAccounts: operativeData.destinationAccountsNotVisibles,
                                                                originAccount: originAccount)
        subscribeDestinationAccounts(input)
    }
    
    func hasFilteredAccounts(visibleAccounts: [AccountRepresentable], notVisibleAccounts: [AccountRepresentable]) -> Bool {
        let totalItems = visibleAccounts.count + notVisibleAccounts.count
        let originalItemsWithoutSelectedAccount = (operativeData.destinationAccountsVisibles + operativeData.destinationAccountsNotVisibles)
            .filter { !$0.equalsTo(other: operativeData.originAccount) }
        let totalItemsWithoutSelectedAccount = originalItemsWithoutSelectedAccount.count
        return totalItemsWithoutSelectedAccount > totalItems
    }
}

// MARK: - Subscriptions

private extension InternalTransferDestinationAccountViewModel {
    func subscribeDestinationAccounts(_ input: GetInternalTransferDestinationAccountsInput) {
        destinationAccountsPublisher(input)
            .sink { [weak self] result in
                guard let self = self else { return }
                let hasFilteredAcccounts = self.hasFilteredAccounts(visibleAccounts: result.visibleAccounts,
                                                               notVisibleAccounts: result.notVisibleAccounts)
                let loadedData = InternalTransferLoadedData(originAccount: input.originAccount,
                                                            visibleAccounts: result.visibleAccounts,
                                                            notVisibleAccounts: result.notVisibleAccounts,
                                                            selectedAccount: self.operativeData.destinationAccount,
                                                            showFilteredAccountsMessage: hasFilteredAcccounts)
                self.stateSubject.send(.loaded(loadedData))
            }
            .store(in: &anySubscriptions)
    }
}

// MARK: - Publishers

private extension InternalTransferDestinationAccountViewModel {
    func destinationAccountsPublisher(_ input: GetInternalTransferDestinationAccountsInput) -> AnyPublisher<GetInternalTransferDestinationAccountsOutput, Never> {
        return getDestinationAccounts
            .fetchAccounts(input: input)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Analytics
extension InternalTransferDestinationAccountViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: InternalTransferDestinationAccountSelectorPage {
        InternalTransferDestinationAccountSelectorPage()
    }
}
