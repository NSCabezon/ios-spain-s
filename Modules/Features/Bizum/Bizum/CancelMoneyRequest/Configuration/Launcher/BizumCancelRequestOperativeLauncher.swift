import Operative
import CoreFoundationLib

public protocol BizumCancelRequestOperativeLauncher: OperativeContainerLauncher {
    func showBizumCancelRequest(operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

extension BizumCancelRequestOperativeLauncher {
    public func showBizumCancelRequest(operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler) {
        let dependencies = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(on: dependencies, handler: handler)
        handler.showOperativeLoading {
            Scenario(useCase: dependencies.resolve(for: BizumTypeUseCase.self), input: BizumTypeUseCaseInput(type: .cancelRequest))
                .execute(on: dependencies.resolve())
                .onSuccess { result in
                    switch result {
                    case .native(bizumCheckPayment: let checkPayment):
                        break
                    case .web(configuration: let configuration):
                        handler.hideOperativeLoading {
                            self.goToBizumWeb(configuration: configuration)
                        }
                    }
                }.onError { error in
                    handler.hideOperativeLoading {
                        handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                    }
                }
        }
    }
}

private extension BizumCancelRequestOperativeLauncher {
    
    func setupDependencies(on dependencies: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependencies.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumGoToHomeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
        dependencies.register(for: BizumTypeUseCase.self) { resolver in
            return BizumTypeUseCase(dependenciesResolver: resolver)
        }
    }
}
