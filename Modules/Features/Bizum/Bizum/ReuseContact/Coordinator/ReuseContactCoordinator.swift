//
//  ReuseContactCoordinator.swift
//  Bizum
//
//  Created by Margaret López Calderón on 16/11/2020.
//

import UI
import CoreFoundationLib
import Operative

protocol ReuseContactCoordinatorProtocol {
    func didSelectDismiss()
    func didSelectGoToSendMoney(_ contacts: [BizumContactEntity])
    func didSelectGoToRequestMoney(_ contacts: [BizumContactEntity])
}

final class ReuseContactCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }

    func start() {
        let viewController = self.dependenciesEngine.resolve(for: ReuseContactViewController.self)
        let transitioningDelegate = HalfSizePresentationManager()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitioningDelegate
        viewController.modalTransitionStyle = .coverVertical
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
}

extension ReuseContactCoordinator: ReuseContactCoordinatorProtocol {
    func didSelectDismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func didSelectGoToSendMoney(_ contacts: [BizumContactEntity]) {
        self.dismiss {
            self.delegate.goToBizumSendMoney(contacts)
        }
    }

    func didSelectGoToRequestMoney(_ contacts: [BizumContactEntity]) {
        self.dismiss {
            self.delegate.goToBizumRequestMoney(contacts)
        }
    }
}

private extension ReuseContactCoordinator {
    var delegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }

    func setupDependencies() {
        self.dependenciesEngine.register(for: ReuseContactCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: ReuseContactPresenterProtocol.self) {  dependenciesResolver in
            let detailOperationConfiguration: BizumDetailOperationConfiguration = dependenciesResolver.resolve()
            let presenter = ReuseContactPresenter(dependenciesResolver: dependenciesResolver, contacts: detailOperationConfiguration.contacts)
            return presenter
        }
        self.dependenciesEngine.register(for: ReuseContactViewController.self) { dependenciesResolver in
            var presenter: ReuseContactPresenterProtocol = dependenciesResolver.resolve()
            let viewController = ReuseContactViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        self.navigationController?.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}
