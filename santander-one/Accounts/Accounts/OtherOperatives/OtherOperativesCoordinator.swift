//
//  OtherOperativesCoordinator.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 05/12/2019.
//

import CoreFoundationLib
import UI

final class OtherOperativesCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    weak var rootViewController: OtherOperativesViewController?
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let accountDetailCoordinator: AccountDetailCoordinator
    private lazy var accountOtherOperativesActionModifier: AccountOtherOperativesActionModifierProtocol = {
            return self.dependenciesEngine.resolve(firstTypeOf: AccountOtherOperativesActionModifierProtocol.self)
        }()
    
    init(resolver: DependenciesResolver, coordinatingViewController controller: UINavigationController?) {
        
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = controller
        self.dependenciesEngine.register(for: OtherOperativesPresenterProtocol.self) { dependenciesResolver in
            return OtherOperativesPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.accountDetailCoordinator = AccountDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.dependenciesEngine.register(for: OtherOperativesViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: OtherOperativesViewController.self)
        }
        
        self.dependenciesEngine.register(for: OtherOperativesViewController.self) { dependenciesResolver in
            let presenter: OtherOperativesPresenterProtocol = dependenciesResolver.resolve(for: OtherOperativesPresenterProtocol.self)
            let viewController = OtherOperativesViewController(nibName: "OtherOperativesViewController", bundle: Bundle.module, presenter: presenter)
            self.rootViewController = viewController
            viewController.modalPresentationStyle = .fullScreen
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GetOtherOperativesUseCase.self) { dependenciesResolver in
            return GetOtherOperativesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: OtherOperativesCoordinator.self) { _ in
            return self
        }
    }
    
    func start() {
        self.navigationController?.present(dependenciesEngine.resolve(for: OtherOperativesViewController.self),
                                           animated: true, completion: nil)
    }
    
    func dismiss() {
        self.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func goToAction(type: AccountActionType, account: AccountEntity) {
        self.rootViewController?.dismiss(animated: true) {
            switch type {
            case .accountDetail:
                self.goToAccountDetail(account: account)
            default:
                self.accountOtherOperativesActionModifier.didSelectAction(type, account)
            }
        }
    }
    
    func goToAccountDetail(account: AccountEntity) {
        self.dependenciesEngine.register(for: AccountDetailConfiguration.self) { _ in
            return AccountDetailConfiguration(accountEntity: account)
        }
        self.accountDetailCoordinator.start()
    }
}
