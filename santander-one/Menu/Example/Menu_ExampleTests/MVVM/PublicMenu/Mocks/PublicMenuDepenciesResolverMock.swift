@testable import Menu

struct PublicMenuDependenciesResolverMock: PublicMenuDependenciesResolver {
    var external: PublicMenuSceneExternalDependenciesResolver
    var comercialSegmentUseCase: GetUserCommercialSegmentUseCaseSpy
    var homeTipsUseCase: GetHomeTipsCountUseCaseSpy
    var publicMenuUseCase: GetPublicMenuConfigurationUseCaseSpy
    var menuCoordinator: PublicMenuCoordinatorSpy
    
    init(externalDepencies: PublicMenuSceneExternalDependenciesResolver) {
        self.external = externalDepencies
        self.comercialSegmentUseCase = GetUserCommercialSegmentUseCaseSpy()
        self.homeTipsUseCase = GetHomeTipsCountUseCaseSpy()
        self.publicMenuUseCase = GetPublicMenuConfigurationUseCaseSpy()
        self.menuCoordinator = PublicMenuCoordinatorSpy()
    }
    
    func resolve() -> PublicMenuViewController {
        return PublicMenuViewController(dependencies: self)
    }
    
    func resolve() -> PublicMenuViewModel {
        return PublicMenuViewModel(dependencies: self)
    }
    
    func resolve() -> GetPublicMenuConfigurationUseCase {
        return self.publicMenuUseCase
    }
    
    func resolve() -> GetUserCommercialSegmentUseCase {
        return self.comercialSegmentUseCase
    }
    
    func resolve() -> GetHomeTipsCountUseCase {
        return self.homeTipsUseCase
    }
    
    func resolve() -> PublicMenuCoordinator {
        return self.menuCoordinator
    }
}
