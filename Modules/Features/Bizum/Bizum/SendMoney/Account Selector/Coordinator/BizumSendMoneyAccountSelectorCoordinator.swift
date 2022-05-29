//
//  BizumSendMoneyAccountSelectorCoordinator.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 26/1/21.
//

import UI
import CoreFoundationLib

protocol BizumSendMoneyAccountSelectorCoordinatorDelegate: class {
    func accountSelectorDidSelectAccount(_ account: AccountEntity)
}

protocol BizumSendMoneyAccountSelectorCoordinatorProtocol {
    func dismiss()
    func dismissWithAccount(_ account: AccountEntity)
}

final class BizumSendMoneyAccountSelectorCoordinator: ModuleCoordinator, BizumSendMoneyAccountSelectorCoordinatorProtocol {
    
    weak var navigationController: UINavigationController?
    private weak var delegate: BizumSendMoneyAccountSelectorCoordinatorDelegate?
    private let dependencies: DependenciesResolver & DependenciesInjector
    
    init(navigationController: UINavigationController, dependenciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupBizumSendMoneyAccountSelector()
    }
    
    func start() {
        self.delegate = self.dependencies.resolve(for: BizumSendMoneyAccountSelectorCoordinatorDelegate.self)
        let viewController = self.dependencies.resolve(for: BizumSendMoneyAccountSelectorViewController.self)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController?.present(navigationController, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.presentedViewController?.dismiss(animated: true)
    }
    
    func dismissWithAccount(_ account: AccountEntity) {
        self.dismiss()
        self.delegate?.accountSelectorDidSelectAccount(account)
    }
}

private extension BizumSendMoneyAccountSelectorCoordinator {
    
    func setupBizumSendMoneyAccountSelector() {
        self.dependencies.register(for: BizumSendMoneyAccountSelectorCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependencies.register(for: BizumSendMoneyAccountSelectorPresenterProtocol.self) { resolver in
            return BizumSendMoneyAccountSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumSendMoneyAccountSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSendMoneyAccountSelectorPresenterProtocol.self)
            let viewController = BizumSendMoneyAccountSelectorViewController(nibName: "BizumSendMoneyAccountSelectorViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
