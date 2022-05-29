import UIKit
import Login
import CoreFoundationLib
import LoginCommon
import RetailLegacy

struct LoginNavigationDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        dependenciesEngine.register(for: LoginModuleCoordinatorProtocol.self) { dependenciesResolver in
            return LoginModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: drawer.currentRootViewController as? UINavigationController)
        }
    }
}
