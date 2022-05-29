//
//  EasyPayOperative.swift
//  Cards
//
//  Created by alvola on 01/12/2020.
//

import Operative
import CoreFoundationLib
import UI
import CoreDomain

final class EasyPayOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    var dependenciesResolver: DependenciesResolver {
        return dependencies
    }
    lazy var operativeData: EasyPayOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    
    var isShareable = true
    var needsReloadGP = true
    
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        return self.dependencies.resolve(for: EasyPayFinishingCoordinatorProtocol.self)
    }()
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
}

private extension EasyPayOperative {
    
    func buildSteps() {
        guard container != nil else { return }
        if operativeData.isSelectorVisible {
            self.steps.append(dependencies.resolve(for: EasyPaySelectorOperativeStep.self))
        }
        self.steps.append(dependencies.resolve(for: EasyPayConfigurationOperativeStep.self))
        self.steps.append(dependencies.resolve(for: EasyPaySummaryStep.self))
    }
    
    func executePerformPreSetup(for delegate: OperativeLauncherHandler, container: OperativeContainerProtocol, completion: @escaping (Bool, OperativeSetupError?) -> Void) {
        let input = PreSetupEasyPayUseCaseInput(isProductSelected: operativeData.productSelected != nil)
        let usecase = dependencies.resolve(firstTypeOf: PreSetupEasyPayUseCase.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
                       queuePriority: Operation.QueuePriority.veryHigh,
                       onSuccess: { [weak self] result in
                        self?.operativeData.updatePre(cardTransactions: result.cardTransactions)
                        completion(true, nil)
            })
    }
}

extension EasyPayOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        let handler = dependencies.resolve(for: OperativeLauncherHandler.self)
        let completion: (Bool, OperativeSetupError?) -> Void = {
            guard let error = $1 else { return success() }
            failed(error)
        }
        executePerformPreSetup(for: handler, container: container, completion: completion)
    }
}

extension EasyPayOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let cardTransactionWithCard = operativeData.productSelected  else { return success() }
        let input = SetupEasyPayUseCaseInput(card: cardTransactionWithCard.cardEntity,
                                             cardTransaction: cardTransactionWithCard.cardTransactionEntity)
        let useCase =  dependencies.resolve(for: SetupEasyPayUseCase.self)
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.operativeData.update(cardDetail: result.cardDetail,
                                           cardTransactionDetail: result.cardTransactionDetail,
                                           easyPayContractTransaction: result.easyPayContractTransaction,
                                           easyPay: result.easyPay,
                                           feeData: result.feeData)
                success()
            },
            onError: { [weak self] error in
                let handler = self?.dependencies.resolve(for: OperativeLauncherHandler.self)
                handler?.hideOperativeLoading {
                    guard let err = error as? SetupEasyPayUseCaseErrorOutput, case .notAllowedMovementToFinance = err.reason  else {
                        handler?.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                        return
                    }
                    handler?.showOperativeAlertError(keyTitle: nil, keyDesc: "easyPay_alert_notPostponeMoves", completion: nil)
                }
            }
        )
    }
}

extension EasyPayOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-pago-facil-exito")
    }
}

extension EasyPayOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-pago-facil-abandono")
    }
}

extension EasyPayOperative: OperativeFinishingCoordinatorCapable {}

extension EasyPayOperative: OperativeGlobalPositionReloaderCapable {}

extension EasyPayOperative: ShareOperativeCapable {
    
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container else { return completion(.failure(.generalError)) }
        let operativeData: EasyPayOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { response in
                let shareView = ShareEasyPayView()
                let viewModel = ShareEasyPaySummaryViewModel(
                    amount: operativeData.easyPayContractTransaction?.amount,
                    operativeNumberOfFees: operativeData.easyPayAmortization?.amortizations.count,
                    operativeConcept: operativeData.productSelected?.cardTransactionEntity.description,
                    operativeStartDate: operativeData.easyPayAmortization?.amortizations.first?.nextAmortizationDate,
                    operativeEndDate: operativeData.easyPayAmortization?.amortizations.last?.nextAmortizationDate)
                viewModel.setUserName(response.globalPosition.fullName)
                shareView.modalPresentationStyle = .fullScreen
                shareView.loadViewIfNeeded()
                shareView.setInfoFromSummary(viewModel)
                completion(.success((shareView, shareView.containerView)))
            }
            .onError { _ in
                completion(.failure(.generalError))
            }
    }
}
