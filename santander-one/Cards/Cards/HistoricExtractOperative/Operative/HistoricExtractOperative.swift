//
//  HistoricExtractOperative.swift
//  Cards
//
//  Created by Ignacio González Miró on 12/11/2020.
//

import CoreFoundationLib
import Operative

final class HistoricExtractOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: HistoricExtractOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: HistoricExtractOperativeFinishingCoordinatorProtocol.self)
    }()
    
    enum FinishingOption {
        case historicExtract
    }
    
    var steps: [OperativeStep] = []
    var useCaseHandler: UseCaseHandler {
        return self.dependencies.resolve(for: UseCaseHandler.self)
    }
    private let externalDependencies: CardExternalDependenciesResolver
    
    init(dependencies: DependenciesInjector & DependenciesResolver,
         externalDependencies: CardExternalDependenciesResolver) {
        self.dependencies = dependencies
        self.externalDependencies = externalDependencies
        self.setupDependencies()
    }
}

private extension HistoricExtractOperative {
    // MARK: Main methods
    func setupDependencies() {
        setupExtractHistoric()
    }
    
    func buildSteps() {
        self.addSteps()
    }
    
    // MARK: Secondary methods
    func addSteps() {
        self.steps.append(HistoricExtractSteps(dependenciesResolver: dependencies))
    }
    
    func setupExtractHistoric() {
        self.dependencies.register(for: HistoricExtractOperativeFinishingCoordinator.self) { resolver in
            return HistoricExtractOperativeFinishingCoordinator(dependenciesResolver: resolver, navigationController: self.container?.coordinator.navigationController, externalDependencies: self.externalDependencies)
        }
        self.dependencies.register(for: HistoricExtractUseCase.self) { resolver in
            return HistoricExtractUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: HistoricExtractPresenterProtocol.self) { resolver in
            return HistoricExtractPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: HistoricExtractViewProtocol.self) { resolver in
            return resolver.resolve(for: HistoricExtractViewController.self)
        }
        self.dependencies.register(for: HistoricExtractViewController.self) { resolver in
            let presenter = resolver.resolve(for: HistoricExtractPresenterProtocol.self)
            let viewController = HistoricExtractViewController(nibName: "HistoricExtractViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension HistoricExtractOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        UseCaseWrapper(with: self.dependencies.resolve(for: HistoricExtractUseCase.self).setRequestValues(requestValues: GetHistoricExtractUseCaseInput(card: operativeData.card, differenceBetweenMonths: 0)), useCaseHandler: useCaseHandler.self, onSuccess: { (result) in
            guard let cardSettlementDetailEntity = result.cardSettlementDetailEntity, let container = self.container else {
                return
            }
            let extractHistoricData: HistoricExtractOperativeData = container.get()
            extractHistoricData.cardSettlementDetailEntity = cardSettlementDetailEntity
            extractHistoricData.currentPaymentMethod = result.currentPaymentMethod
            extractHistoricData.currentPaymentMethodMode = result.currentPaymentMethodMode
            extractHistoricData.settlementMovements = !cardSettlementDetailEntity.emptyMovements ? result.settlementMovementsList : []
            extractHistoricData.cardDetail = result.cardDetailEntity
            extractHistoricData.scaDate = result.scaDate
            extractHistoricData.isMultipleMapEnabled = result.isEnableCardsHomeLocationMap
            container.save(extractHistoricData)
            success()
        }, onError: { (error) in
            failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
        })
    }
}
