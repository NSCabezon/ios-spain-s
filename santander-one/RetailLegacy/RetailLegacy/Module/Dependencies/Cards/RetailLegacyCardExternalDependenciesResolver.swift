import UI
import CoreFoundationLib
import Foundation

public protocol RetailLegacyCardExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func cardActivateCoordinator() -> BindableCoordinator
}

public extension RetailLegacyCardExternalDependenciesResolver {
     
    func cardActivateCoordinator() -> BindableCoordinator {
        return DefaultCardActivateCoordinator(dependencies: self)
    }
}

