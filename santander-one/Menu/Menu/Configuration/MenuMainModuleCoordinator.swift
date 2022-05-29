import CoreFoundationLib
import UI
import SANLegacyLibrary

public protocol MenuMainModuleCoordinatorDelegate: AnyObject {
    func didSelectHelpCenter()
}

public class MenuMainModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: MenuViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    public func startOnHelpCenter() {
        self.didSelectHelpCenter()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: MenuPresenterProtocol.self) { dependenciesResolver in
            return MenuPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MenuViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: MenuViewController.self)
        }
        
        self.dependenciesEngine.register(for: MenuViewController.self) { dependenciesResolver in
            var presenter: MenuPresenterProtocol = dependenciesResolver.resolve(for: MenuPresenterProtocol.self)
            let viewController = MenuViewController(nibName: "Menu", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension MenuMainModuleCoordinator: MenuMainModuleCoordinatorDelegate {
    public func didSelectHelpCenter() {
        guard let privateMenuModifier = dependenciesEngine.resolve(forOptionalType: PrivateMenuProtocol.self) else {
            let coordinator = HelperCenterCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
            coordinator.start()
            return
        }
        privateMenuModifier.goToHelpCenterPage()
    }
}
