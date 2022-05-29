import Foundation
import Operative
import CoreFoundationLib

public protocol BizumCancelLauncher: OperativeContainerLauncher {
    func goToBizumCancel(_ operationEntity: BizumHistoricOperationEntity, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

public extension BizumCancelLauncher {
    func goToBizumCancel(_ operationEntity: BizumHistoricOperationEntity, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        setupDependencies(in: dependenciesEngine, handler: handler)
        let useCase = dependenciesEngine.resolve(for: BizumTypeUseCase.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: BizumTypeUseCaseInput(type: .cancelNotRegister)),
                       useCaseHandler: dependenciesEngine.resolve(for: UseCaseHandler.self),
                       onSuccess: { result in
                        switch result {
                        case .native(let bizumCheckPaymentEntity):
                            self.setupDependencies(in: dependenciesEngine, handler: handler)
                            let operative = BizumCancelOperative(dependencies: dependenciesEngine)
                            let operativeData = BizumCancelOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity, operationEntity: operationEntity)
                            self.go(to: operative, handler: handler, operativeData: operativeData)
                        case .web(let configuration):
                            self.goToBizumWeb(configuration: configuration)
                        }
        }, onError: { error in
            handler.hideOperativeLoading {
                handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        dependenciesInjector.register(for: BizumTypeUseCase.self) { _ in
            return BizumTypeUseCase(dependenciesResolver: dependenciesEngine)
        }
        dependenciesInjector.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumGoToHomeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
    }
}
