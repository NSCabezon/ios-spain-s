import Operative
import CoreFoundationLib

public protocol BizumRefundMoneyOperativeLauncher: OperativeContainerLauncher {
    func showBizumRefundMoney(operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

extension BizumRefundMoneyOperativeLauncher {
    public func showBizumRefundMoney(operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler) {
        let dependencies = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(on: dependencies, handler: handler)
        handler.showOperativeLoading {
            Scenario(useCase: dependencies.resolve(for: BizumTypeUseCase.self), input: BizumTypeUseCaseInput(type: .refundMoney))
                .execute(on: dependencies.resolve())
                .onSuccess { result in
                    switch result {
                    case .native(bizumCheckPayment: let checkPayment):
                        self.goToBizumNative(operation: operation, checkPayment: checkPayment, handler: handler, dependenciesResolver: dependencies)
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

private extension BizumRefundMoneyOperativeLauncher {
    
    func setupDependencies(on dependencies: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependencies.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumGoToHomeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
        dependencies.register(for: BizumTypeUseCase.self) { resolver in
            return BizumTypeUseCase(dependenciesResolver: resolver)
        }
    }
    
    func goToBizumNative(operation: BizumHistoricOperationEntity, checkPayment: BizumCheckPaymentEntity, handler: OperativeLauncherHandler, dependenciesResolver: DependenciesResolver) {
        guard let amount = operation.amount.flatMap({ AmountEntity(value: Decimal($0)) }) else { return }
        let operative = BizumRefundMoneyOperative(dependenciesResolver: dependenciesResolver)
        let operativeData = BizumRefundMoneyOperativeData(
            totalAmount: amount,
            operation: operation,
            checkPayment: checkPayment
        )
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}
