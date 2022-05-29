//
//  EasyPayLauncher.swift
//  Cards
//
//  Created by alvola on 01/12/2020.
//

import CoreFoundationLib
import Operative

public protocol EasyPayLauncher: OperativeContainerLauncher {
    func showEasyPay(product: CardTransactionWithCardEntity?,
                     operativeDataEntity: EasyPayOperativeDataEntity?,
                     handler: OperativeLauncherHandler)
}

public extension EasyPayLauncher {
    func showEasyPay(product: CardTransactionWithCardEntity?,
                     operativeDataEntity: EasyPayOperativeDataEntity?,
                     handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = EasyPayOperative(dependencies: dependenciesEngine)
        let operativeData = setupOperativeData(product, operativeDataEntity)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension EasyPayLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        setupStepsDependencies(in: dependenciesInjector)
        dependenciesInjector.register(for: PreSetupEasyPayUseCase.self) { resolver in
            return DefaultPreSetupEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: SetupEasyPayUseCase.self) { resolver in
            return SetupEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: OperativeLauncherHandler.self) { _ in
            return handler
        }
        dependenciesInjector.register(for: EasyPayFinishingCoordinatorProtocol.self) { resolver in
            return EasyPayFinishingCoordinator(navigationController: handler.operativeNavigationController,
                                               resolver: resolver)
        }
    }
    
    func setupStepsDependencies(in dependenciesInjector: DependenciesInjector) {
        registerSelectorDependencies(in: dependenciesInjector)
        registerConfigurationStepDependencies(in: dependenciesInjector)
        registerSummaryDependencies(in: dependenciesInjector)
    }
    
    func registerConfigurationStepDependencies(in dependenciesInjector: DependenciesInjector) {
        dependenciesInjector.register(for: EasyPayConfigurationOperativeStep.self) { resolver in
            return EasyPayConfigurationOperativeStep(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: EasyPaySummaryStep.self) { resolver in
            return EasyPaySummaryStep(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: EasyPayConfigurationPresenterProtocol.self) { resolver in
            return EasyPayConfigurationPresenter(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: ValidateEasyPayUseCase.self) { resolver in
            return ValidateEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: ConfirmEasyPayUseCase.self) { resolver in
            return ConfirmEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: FirstFeeInfoEasyPayUseCase.self) { resolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: EasyPayConfigurationViewProtocol.self) { resolver in
            let presenter = resolver.resolve(for: EasyPayConfigurationPresenterProtocol.self)
            let viewController = EasyPayConfigurationViewController(nibName: "EasyPayConfigurationViewController",
                                                                    bundle: .module,
                                                                    presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func registerSummaryDependencies(in dependenciesInjector: DependenciesInjector) {
        dependenciesInjector.register(for: EasyPaySummaryPresenterProtocol.self) { resolver in
            return EasyPaySummaryPresenter(dependenciesResolver: resolver)
        }
        
        dependenciesInjector.register(for: OperativeSummaryViewProtocol.self) { resolver in
            let presenter = resolver.resolve(for: EasyPaySummaryPresenterProtocol.self)
            let viewController = EasyPaySummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        dependenciesInjector.register(for: GetFinancingUseCase.self) { resolver in
            return GetFinancingUseCase(resolver: resolver)
        }
        
        dependenciesInjector.register(for: GetGlobalPositionUseCaseAlias.self) { resolver in
            return GetGlobalPositionUseCase(dependenciesResolver: resolver)
        }
    }
    
    func registerSelectorDependencies(in dependenciesInjector: DependenciesInjector) {
        dependenciesInjector.register(for: EasyPaySelectorOperativeStep.self) { resolver in
            return EasyPaySelectorOperativeStep(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: EasyPaySelectorPresenterProtocol.self) { resolver in
            return EasyPaySelectorPresenter(dependenciesResolver: resolver)
        }
        dependenciesInjector.register(for: EasyPaySelectorViewProtocol.self) { resolver in
            let presenter = resolver.resolve(for: EasyPaySelectorPresenterProtocol.self)
            let viewController = EasyPaySelectorViewController(nibName: "EasyPaySelectorViewController",
                                                               bundle: .module,
                                                               presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupOperativeData(_ product: CardTransactionWithCardEntity?,
                            _ operativeDataEntity: EasyPayOperativeDataEntity?) -> EasyPayOperativeData {
        let operativeData = EasyPayOperativeData(product: product)
        if let data = operativeDataEntity {
            let cardDetail = CardDetailEntity(data.cardDetail.dto,
                                              cardDataDTO: data.cardDetail.cardDataDTO,
                                              clientName: data.cardDetail.clientName ?? "")
            operativeData.update(cardDetail: cardDetail,
                                 cardTransactionDetail: CardTransactionDetailEntity(data.cardTransactionDetail.dto),
                                 easyPayContractTransaction: EasyPayContractTransactionEntity(data.easyPayContractTransaction.dto),
                                 easyPay: EasyPayEntity(data.easyPay.dto),
                                 feeData: FeeDataEntity(data.feeData.dto))
            guard let easyPayAmortization = data.easyPayAmortization else { return operativeData }
            operativeData.easyPayAmortization = EasyPayAmortizationEntity(easyPayAmortization.dto)
        }
        return operativeData
    }
}
