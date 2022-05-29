import CoreFoundationLib
import UI

public protocol StockholdersExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func publicMenuStockholdersCoordinator() -> Coordinator
}

extension StockholdersExternalDependenciesResolver {
    public func publicMenuStockholdersCoordinator() -> Coordinator {
        return DefaultStockholdersCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
