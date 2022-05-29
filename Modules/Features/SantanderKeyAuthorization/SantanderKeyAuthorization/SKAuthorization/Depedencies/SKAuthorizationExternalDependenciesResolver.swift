import UI
import CoreFoundationLib
import OpenCombine
import UIKit

public protocol SKAuthorizationExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func skAuthorizationCoordinator() -> BindableCoordinator
}

public extension SKAuthorizationExternalDependenciesResolver {
    func skAuthorizationCoordinator() -> BindableCoordinator {
        return DefaultSKAuthorizationCoordinator(dependencies: self, navigationController: resolve())
    }
}
