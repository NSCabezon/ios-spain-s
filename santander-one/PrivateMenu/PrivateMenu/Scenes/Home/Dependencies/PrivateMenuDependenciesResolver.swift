import CoreFoundationLib

protocol PrivateMenuDependenciesResolver {
    var external: PrivateMenuExternalDependenciesResolver { get }
    func resolve() -> PrivateMenuViewController
    func resolve() -> DataBinding
    func resolve() -> PrivateMenuCoordinator
    func resolve() -> PrivateMenuViewModel
}

extension PrivateMenuDependenciesResolver {
    func resolve() -> PrivateMenuViewModel {
      return PrivateMenuViewModel(dependencies: self)
    }
    
    func resolve() -> PrivateMenuViewController {
        return PrivateMenuViewController(dependencies: self)
    }
}
