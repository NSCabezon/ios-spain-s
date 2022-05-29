import OpenCombine
import UI
import CoreDomain
import CoreFoundationLib

protocol PublicMenuCoordinator: BindableCoordinator {
    func openUrl(_ url: String)
    func goToAtmLocator()
    func goToStockholders()
    func goToOurProducts()
    func toggleSideMenu()
    func goToHomeTips()
    func goToCustomAction()
    func comingSoon()
    func goToPublicOffer(offer: OfferRepresentable)
}

public final class DefaultPublicMenuCoordinator {
    weak public var navigationController: UINavigationController?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: PublicMenuSceneExternalDependenciesResolver
    lazy public var dataBinding: DataBinding = dependencies.resolve()
    public var onFinish: (() -> Void)?
    
    private lazy var dependencies: Dependency = {
        return Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: PublicMenuSceneExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.externalDependencies = dependencies
        self.navigationController = navigationController
    }
}

extension DefaultPublicMenuCoordinator: PublicMenuCoordinator, OpenUrlCapable {
    public func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString),
              canOpenUrl(url)
        else { return }
        openUrl(url)
    }
    
    func goToAtmLocator() {
        let coordinator = dependencies.external.publicMenuATMLocatorCoordinator()
        coordinator
            .set(false)
            .start()
        append(child: coordinator)
    }
    
    func goToStockholders() {
        let coordinator = dependencies.external.publicMenuStockholdersCoordinator()
        goToCoordinator(coordinator)
    }
    
    func goToOurProducts() {
        let coordinator = dependencies.external.publicMenuOurProductsCoordinator()
        goToCoordinator(coordinator)
    }
    
    func toggleSideMenu() {
        let outsider: PublicMenuToggleOutsider = dependencies.external.resolve()
        outsider.toggleSideMenu()
    }
    
    func goToHomeTips() {
        let coordinator = dependencies.external.publicMenuHomeTipsCoordinator()
        goToCoordinator(coordinator)
    }
    
    func goToCustomAction() {
        guard let action: String = dataBinding.get() else { return }
        let coordinator = dependencies.external.publicMenuCustomCoordinatorForAction()
        coordinator
            .set(action)
            .start()
        append(child: coordinator)
    }
    
    func comingSoon() {
        goToCoordinator(ToastCoordinator("generic_alert_notAvailableOperation"))
    }
    
    func goToPublicOffer(offer: OfferRepresentable) {
        let coordinator = dependencies.external.resolveOfferCoordinator()
        coordinator
            .set(offer)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultPublicMenuCoordinator {
    func goToCoordinator(_ coordinator: Coordinator) {
        coordinator.start()
        append(child: coordinator)
    }
    
    struct Dependency: PublicMenuDependenciesResolver {
        let dependencies: PublicMenuSceneExternalDependenciesResolver
        let coordinator: PublicMenuCoordinator
        let dataBinding = DataBindingObject()
        
        var external: PublicMenuSceneExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> PublicMenuCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
