import UIKit
import CoreFoundationLib
import RetailLegacy

struct DeeplinkDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        dependenciesEngine.register(for: CustomDeeplinkLauncher.self) { dependenciesResolver in
            return DeeplinkLauncher(dependenciesResolver: dependenciesResolver)
        }
    }
}
