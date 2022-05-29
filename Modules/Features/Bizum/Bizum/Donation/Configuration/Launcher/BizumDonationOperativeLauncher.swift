import Operative
import CoreFoundationLib

public protocol BizumDonationOperativeLauncher: OperativeContainerLauncher {
    func goToBizumDonation(handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

public extension BizumDonationOperativeLauncher {
    func goToBizumDonation(handler: OperativeLauncherHandler) {
        let dependencies = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependencies, handler: handler)
        handler.showOperativeLoading {
            self.executeUseCase(handler: handler, dependencies: dependencies)
        }
    }
}

private extension BizumDonationOperativeLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumGoToHomeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
        dependenciesInjector.register(for: BizumTypeUseCase.self) { resolver in
            BizumTypeUseCase(dependenciesResolver: resolver)
        }
    }

    func executeUseCase(handler: OperativeLauncherHandler, dependencies: DependenciesDefault) {
        Scenario(useCase: dependencies.resolve(for: BizumTypeUseCase.self),
                 input: BizumTypeUseCaseInput(type: .donations, webViewType: .donation))
            .execute(on: dependencies.resolve())
            .onSuccess { result in
                switch result {
                case .native(let bizumCheckPaymentEntity):
                    let operative = BizumDonationOperative(dependencies: dependencies)
                    let operativeData = BizumDonationOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
                    self.go(to: operative, handler: handler, operativeData: operativeData)
                case .web(let configuration):
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
