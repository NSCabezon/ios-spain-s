//
//  AccountDetailCoordinator.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 05/02/2021.
//

import UI
import SANLegacyLibrary
import CoreFoundationLib

public protocol AccountDetailCoordinatorProtocol {
    func doShare(for shareable: Shareable)
    func dismiss()
}

final class AccountDetailCoordinator: ModuleCoordinator {

    private let dependenciesEngine: DependenciesDefault
    weak var navigationController: UINavigationController?
    private lazy var account: AccountEntity? = nil
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        self.navigationController?.blockingPushViewController(dependenciesEngine.resolve(for: AccountDetailViewController.self), animated: true)
    }
}

private extension AccountDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: AccountDetailPresenterProtocol.self) { dependenciesResolver in
            return AccountDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AccountDetailViewController.self) { dependenciesResolver in
            let presenter: AccountDetailPresenterProtocol = dependenciesResolver.resolve(for: AccountDetailPresenterProtocol.self)
            let viewController = AccountDetailViewController(nibName: "AccountDetailViewController", bundle: Bundle.module, presenter: presenter, dependenciesResolver: self.dependenciesEngine)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: AccountDetailCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetAccountDetailUseCase.self) { dependenciesResolver in
            return GetAccountDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ChangeAliasDetailUseCaseProtocol.self) { dependenciesResolver in
            return ChangeAliasDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        self.dependenciesEngine.register(for: ChangeAccountMainUseCaseAlias.self) { resolver in
            return ChangeAccountMainUseCase(dependenciesResolver: resolver)
        }
    }
}

extension AccountDetailCoordinator: AccountDetailCoordinatorProtocol {
    func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandler = self.dependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandler.doShare(for: shareable, in: controller)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
