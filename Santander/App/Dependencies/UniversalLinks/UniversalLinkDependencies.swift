import CoreFoundationLib
import RetailLegacy

final class UniversalLinkDependencies {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let universalLinkManager: UniversalLinkManagerProtocol

    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.dependenciesEngine = dependenciesEngine
        self.universalLinkManager = UniversalLinkManager(drawer: drawer, dependencies: dependenciesEngine)
    }

    func registerDependencies() {
        dependenciesEngine.register(for: UniversalLinkManagerProtocol.self) { _ in
            return self.universalLinkManager
        }
    }
}
