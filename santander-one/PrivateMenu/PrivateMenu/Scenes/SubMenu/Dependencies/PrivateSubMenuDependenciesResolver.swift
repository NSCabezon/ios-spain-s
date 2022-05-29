import CoreFoundationLib

protocol PrivateSubMenuDependenciesResolver {
    var external: PrivateSubMenuExternalDependenciesResolver { get }
    func resolve() -> PrivateSubMenuViewController
    func resolve() -> DataBinding
    func resolve() -> PrivateSubMenuCoordinator
    func resolve() -> PrivateSubMenuViewModel
    func resolve() -> GetImageUseCase
    func resolve() -> GetPrivateSubMenuOptionOffersUseCase
}

extension PrivateSubMenuDependenciesResolver {
    func resolve() -> PrivateSubMenuViewModel {
      return PrivateSubMenuViewModel(dependencies: self)
    }
    
    func resolve() -> PrivateSubMenuViewController {
        return PrivateSubMenuViewController(dependencies: self)
    }
    
    func resolve() -> GetImageUseCase {
        return DefaultGetOfferImageUseCase()
    }
    
    func resolve() -> GetPrivateSubMenuOptionOffersUseCase {
        return DefaultPrivateSubMenuOptionOffersUseCase(dependencies: self)
    }
}
