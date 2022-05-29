import UIKit
import CoreFoundationLib
import Ecommerce
import RetailLegacy
import ESCommons

struct EcommerceNavigationDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: EcommerceMainModuleCoordinatorDelegate.self) { resolver in
            return EcommerceCoordinatorNavigator(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: EmptyPurchasesPresenterDelegate.self) { resolver in
            return EcommerceCoordinatorNavigator(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: EcommerceNavigatorProtocol.self) { _ in
            return EcommerceNavigator(drawer: drawer, dependenciesEngine: dependenciesEngine)
        }
    }
}
