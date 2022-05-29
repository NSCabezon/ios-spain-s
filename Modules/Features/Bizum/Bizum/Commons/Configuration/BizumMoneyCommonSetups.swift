import Operative

protocol BizumMoneyCommonSetups: Operative {
    func setupContacts()
    func setupAmount()
}
extension BizumMoneyCommonSetups {
    func setupContacts() {
        self.dependencies.register(for: BizumContactCoordinatorProtocol.self) { resolver in
            return BizumContactCoordinator(navigationController: self.container?.coordinator.navigationController ?? UINavigationController(), dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumContactPresenterProtocol.self) { resolver in
            BizumContactPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumContactViewProtocol.self) { resolver in
            resolver.resolve(for: BizumContactViewController.self)
        }
        self.dependencies.register(for: BizumContactViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumContactPresenterProtocol.self)
            let viewController = BizumContactViewController(nibName: "BizumContactViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetContactListUseCase.self) { dependenciesResolver in
            return GetContactListUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumCommonPreSetupUseCaseProtocol.self) { resolver in
            BizumCommonPreSetupUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumOperationUseCaseAlias.self) { resolver in
            BizumOperationUseCase(dependenciesResolver: resolver)
        }
    }

    func setupAmount() {
        self.setupCommonAmount()
        self.setupCommonMultimedia()
    }
}

private extension BizumMoneyCommonSetups {
    func setupCommonAmount() {
        self.dependencies.register(for: SignPosSendMoneyUseCase.self) { resolver in
            SignPosSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumAmountPresenterProtocol.self) { resolver in
            BizumAmountPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumSendMoneyViewProtocol.self) { resolver in
            resolver.resolve(for: BizumAmountViewController.self)
        }
        self.dependencies.register(for: BizumAmountViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumAmountPresenterProtocol.self)
            let viewController = BizumAmountViewController(nibName: "BizumAmountViewController", presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupCommonMultimedia() {
        self.dependencies.register(for: GetMultimediaUsersUseCase.self) { resolver in
            GetMultimediaUsersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaSimpleUseCase.self) { resolver in
            SendMultimediaSimpleUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaMultiUseCase.self) { resolver in
            SendMultimediaMultiUseCase(dependenciesResolver: resolver)
        }
    }
}
