import UI
import Foundation
import CoreDomain
import CoreFoundationLib
import Menu

protocol RetailLegacyPublicMenuDependenciesResolver {
    var external: RetailLegacyMenuExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}

final class RetailLegacyPublicMenuCoordinator: BindableCoordinator {
    
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private let externalDependencies: RetailLegacyMenuExternalDependenciesResolver
    lazy public var dataBinding: DataBinding = dependencies.resolve()
    
    private struct PublicMenuCoordinatorATMNavigator: ATMLocatorNavigatable {
        var customNavigation: NavigationController?
    }

    init(dependencies: RetailLegacyMenuExternalDependenciesResolver) {
        self.externalDependencies = dependencies
        self.navigationController = dependencies.resolve()
    }
    
    func start() {
        let keepingNavigation: Bool = dataBinding.get() ?? false
        goToATMLocator(keepingNavigation: keepingNavigation)
    }
    
    public func goToATMLocator(keepingNavigation: Bool) {
        if let navController = self.navigationController as? NavigationController {
            let atmNavigator = PublicMenuCoordinatorATMNavigator(customNavigation: navController)
            atmNavigator.goToATMLocator(keepingNavigation: keepingNavigation)
        }
    }
}

private extension RetailLegacyPublicMenuCoordinator {
    struct Dependency: RetailLegacyPublicMenuDependenciesResolver {
        let dependencies: RetailLegacyMenuExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: RetailLegacyMenuExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
