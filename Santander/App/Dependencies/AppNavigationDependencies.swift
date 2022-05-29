import Login
import CoreFoundationLib
import LoginCommon
import RetailLegacy
import PrivateMenu

struct AppNavigationDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        LoginNavigationDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
        EcommerceNavigationDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
        DeeplinkDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
        BizumNavigationDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
        UniversalLinkDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
        SpainSanKeyTransferDependencies(drawer: drawer, dependenciesEngine: dependenciesEngine).registerDependencies()
    }
}
