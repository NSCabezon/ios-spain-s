import Foundation
import CoreFoundationLib
import UI

public protocol OurProductsExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func publicMenuOurProductsCoordinator() -> Coordinator
}

extension OurProductsExternalDependenciesResolver {
    public func publicMenuOurProductsCoordinator() -> Coordinator {
        return DefaultOurProductsCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
