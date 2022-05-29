import Foundation

@testable import Menu

struct TestPublicMenuDependenciesResolver: PublicMenuDependenciesResolver {
    
    var external: PublicMenuSceneExternalDependenciesResolver
    
    init(externalDependencies: TestExternalDependencies) {
        self.external = externalDependencies
    }
    
    func resolve() -> PublicMenuCoordinator {
        fatalError()
    }
}
