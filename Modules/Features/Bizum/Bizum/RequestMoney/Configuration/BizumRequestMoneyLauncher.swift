import Foundation
import Operative
import CoreFoundationLib

public protocol BizumRequestMoneyLauncher: OperativeContainerLauncher {
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?, sendMoney: BizumSendMoney?, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

public extension BizumRequestMoneyLauncher {
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?, sendMoney: BizumSendMoney?, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        setupDependencies(in: dependenciesEngine, handler: handler)
        handler.showOperativeLoading {
            let useCase = dependenciesEngine.resolve(for: BizumTypeUseCase.self)
            UseCaseWrapper(with: useCase.setRequestValues(requestValues: BizumTypeUseCaseInput(type: .request)),
                           useCaseHandler: dependenciesEngine.resolve(for: UseCaseHandler.self),
                           onSuccess: { result in
                            switch result {
                            case .native(bizumCheckPayment: let bizumCheckPaymentEntity):
                                self.setupDependencies(in: dependenciesEngine, handler: handler)
                                let operative = BizumRequestMoneyOperative(dependencies: dependenciesEngine)
                                let operativeData = BizumRequestMoneyOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
                                operativeData.bizumContactEntity = contacts
                                operativeData.bizumSendMoney = sendMoney
                                self.go(to: operative, handler: handler, operativeData: operativeData)
                            case .web(configuration: let configuration):
                                handler.hideOperativeLoading {
                                    self.goToBizumWeb(configuration: configuration)
                                }
                            }
            }, onError: { error in
                handler.hideOperativeLoading {
                    handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                }                
            })
        }
    }
    
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        dependenciesInjector.register(for: BizumTypeUseCase.self) { _ in
            return BizumTypeUseCase(dependenciesResolver: dependenciesEngine)
        }
        dependenciesInjector.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumSendOrRequestMoneyFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
    }
}
