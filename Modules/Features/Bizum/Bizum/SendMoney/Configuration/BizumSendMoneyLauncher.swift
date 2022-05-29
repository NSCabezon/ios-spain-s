import Operative
import CoreFoundationLib

public protocol BizumSendMoneyLauncher: OperativeContainerLauncher {
    func goToAmountSendMoney(_ contact: BizumContactEntity, handler: OperativeLauncherHandler)
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?, sendMoney: BizumSendMoney?, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

// MARK: - Public Methods
public extension BizumSendMoneyLauncher {
    func goToAmountSendMoney(_ contact: BizumContactEntity, handler: OperativeLauncherHandler) {
        let isFirstStepEnabled = handler.dependenciesResolver
            .resolve(for: AppConfigRepositoryProtocol.self)
            .getBool(BizumConstants.isFirstStepEnabled) ?? false
        self.goToBizumSendMoney(
            contacts: [contact],
            sendMoney: nil,
            handler: handler,
            step: isFirstStepEnabled ? 0 : 1
        )
    }

    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?, sendMoney: BizumSendMoney?, handler: OperativeLauncherHandler) {
        self.goToBizumSendMoney(
            contacts: contacts,
            sendMoney: sendMoney,
            handler: handler,
            step: 0)
    }

    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        dependenciesInjector.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumSendOrRequestMoneyFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
        dependenciesInjector.register(for: BizumTypeUseCase.self) { _ in
            return BizumTypeUseCase(dependenciesResolver: dependenciesEngine)
        }
    }
}

// MARK: - Private Methods

private extension BizumSendMoneyLauncher {
    func goToBizumSendMoney(
        contacts: [BizumContactEntity]?,
        sendMoney: BizumSendMoney?,
        handler: OperativeLauncherHandler,
        step: Int) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        handler.showOperativeLoading {
            let useCase = dependenciesEngine.resolve(for: BizumTypeUseCase.self)
            UseCaseWrapper(
                with: useCase.setRequestValues(requestValues: BizumTypeUseCaseInput(type: .send)),
                useCaseHandler: dependenciesEngine.resolve(for: UseCaseHandler.self),
                onSuccess: { result in
                    switch result {
                    case .native(let bizumCheckPaymentEntity):
                        self.setupDependencies(in: dependenciesEngine, handler: handler)
                        let operative = BizumSendMoneyOperative(dependencies: dependenciesEngine, initialStep: step)
                        let operativeData = BizumSendMoneyOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
                        operativeData.bizumContactEntity = contacts
                        operativeData.bizumSendMoney = sendMoney
                        self.go(to: operative, handler: handler, operativeData: operativeData)
                    case .web(let configuration):
                        self.goToBizumWeb(configuration: configuration)
                    }
                },
                onError: { error in
                    handler.hideOperativeLoading {
                        handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                    }
                })
        }
    }
}
