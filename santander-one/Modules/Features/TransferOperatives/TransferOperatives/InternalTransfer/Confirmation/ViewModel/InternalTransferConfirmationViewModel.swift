//
//  InternalTransferConfirmationViewModel.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 2/3/22.
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Operative

struct InternalTransferConfirmationAlertConfiguration {
    let additionalFeeKey: String
    let additionalFeeLinkKey: String?
    let additionalFeeLink: String?
    let additionalFeeIconKey: String
}

enum InternalTransferConfirmationState: State {
    case idle
    case confirmation
    case loaded(InternalTransferConfirmationLoadedData)
}

struct InternalTransferConfirmationLoadedData {
    let flowItems: [OneListFlowItemViewModel]
    let ammount: AmountRepresentable
    let alert: InternalTransferConfirmationAlertConfiguration?
}

final class InternalTransferConfirmationViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferConfirmationDependenciesResolver
    private lazy var modifier: InternalTransferConfirmationModifierProtocol = dependencies.external.resolve()
    private let stateSubject = CurrentValueSubject<InternalTransferConfirmationState, Never>(.idle)
    private lazy var operative: InternalTransferOperative = dependencies.resolve()
    var state: AnyPublisher<InternalTransferConfirmationState, Never>
    @BindingOptional var operativeData: InternalTransferOperativeData!
    
    init(dependencies: InternalTransferConfirmationDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        setupConfirmationItems()
        trackScreen()
    }
    
    func back() {
        coordinator.back()
    }
    
    func next() {
        coordinator.next()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func setupConfirmationItems() {
        guard let amount = operativeData.amount,
              let origin = operativeData.originAccount,
              let destination = operativeData.destinationAccount else { return }
        let builder = InternalTransferConfirmationBuilder(dependencies: dependencies, operativeData: operativeData)
        builder.addSourceAccount()
        builder.addAmount()
        builder.addExchangeRate()
        builder.addSendDate()
        builder.addDestinationAccount()

        var alert: InternalTransferConfirmationAlertConfiguration?
        if !modifier.freeTransferFor(originAccount: origin, destinationAccount: destination, date: operativeData.issueDate) {
            alert = InternalTransferConfirmationAlertConfiguration(additionalFeeKey: modifier.additionalFeeKey, additionalFeeLinkKey: modifier.additionalFeeLinkKey, additionalFeeLink: modifier.additionalFeeLink, additionalFeeIconKey: modifier.additionalFeeIconKey)
        }

        let internalTransferConfirmationLoadedData = InternalTransferConfirmationLoadedData(flowItems: builder.build(), ammount: amount, alert: alert)
        stateSubject.send(.loaded(internalTransferConfirmationLoadedData))
    }
    
    func sendConfirmation() {
        guard let selectedAccount = operativeData.originAccount,
              let destinationAccount = operativeData.destinationAccount,
              let amount = operativeData.amount
        else { return }
        let input = InternalTransferConfirmationUseCaseInput(originAccount: selectedAccount,
                                                             destinationAccount: destinationAccount,
                                                             name: operativeData.destinationAccount?.alias,
                                                             alias: operativeData.originAccount?.alias,
                                                             debitAmount: amount,
                                                             creditAmount: operativeData.receiveAmount ?? amount,
                                                             concept: operativeData.description,
                                                             type: OnePayTransferType.national,
                                                             time: operativeData.issueDate)
        showLoadingPublisher()
            .flatMap {
                return self.useCase.fetchConfirmation(input: input)
            }
            .flatMap(dismissLoadingPublisher)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .failure: self.showErrorView()
                case .success: self.stateSubject.send(.confirmation)
                }
            }
            .store(in: &anySubscriptions)
    }
}

private extension InternalTransferConfirmationViewModel {
    
    var coordinator: InternalTransferOperativeCoordinator {
        return dependencies.resolve()
    }
    
    var useCase: InternalTransferConfirmationUseCase {
        return dependencies.external.resolve()
    }
    
    func showLoadingPublisher() -> AnyPublisher<Void, Error> {
        return operative.coordinator.showLoadingPublisher().setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func dismissLoadingPublisher(_ conditionState: ConditionState) -> AnyPublisher<ConditionState, Error> {
        return operative.coordinator.dismissLoadingPublisher().setFailureType(to: Error.self)
            .flatMap { Just(conditionState) }
            .eraseToAnyPublisher()
    }
    
    func showErrorView() {
        operative.coordinator.dismissLoading() {
            let internalCoordinator: InternalTransferOperativeCoordinator = self.dependencies.resolve()
            internalCoordinator.showInternalTransferError(InternalTransferOperativeError.genericError)
        }
    }
    
    func getAmountRepresentable() -> AmountRepresentable? {
        var amountRepresentable: AmountRepresentable?
        switch operativeData.transferType {
        case .noExchange: amountRepresentable = operativeData.amount
        default: amountRepresentable = operativeData.receiveAmount
        }
        return amountRepresentable
    }
}

// MARK: Analytics
extension InternalTransferConfirmationViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: InternalTransferConfirmPage {
        InternalTransferConfirmPage()
    }
}
