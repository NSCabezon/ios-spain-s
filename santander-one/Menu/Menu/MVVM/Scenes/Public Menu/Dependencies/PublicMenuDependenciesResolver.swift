protocol PublicMenuDependenciesResolver {
    var external: PublicMenuSceneExternalDependenciesResolver { get }
    func resolve() -> PublicMenuViewController
    func resolve() -> PublicMenuViewModel
    func resolve() -> GetPublicMenuConfigurationUseCase
    func resolve() -> GetUserCommercialSegmentUseCase
    func resolve() -> GetHomeTipsCountUseCase
    func resolve() -> GetPublicMenuOffersUseCase
    func resolve() -> PublicMenuCoordinator
}

extension PublicMenuDependenciesResolver {
    func resolve() -> PublicMenuViewController {
        return PublicMenuViewController(dependencies: self)
    }
    
    func resolve() -> PublicMenuViewModel {
        return PublicMenuViewModel(dependencies: self)
    }
    
    func resolve() -> GetPublicMenuConfigurationUseCase {
        return DefaultGetPublicMenuConfigurationUseCase(dependencies: self)
    }
    
    func resolve() -> GetUserCommercialSegmentUseCase {
        return DefaultGetUserCommercialSegmentUseCase(dependencies: self)
    }
    
    func resolve() -> GetHomeTipsCountUseCase {
        return DefaultGetHomeTipsCountUseCase(dependencies: self)
    }
    
    func resolve() -> GetPublicMenuOffersUseCase {
        return DefaultGetPublicMenuOffersUseCase(dependencies: self)
    }
}
