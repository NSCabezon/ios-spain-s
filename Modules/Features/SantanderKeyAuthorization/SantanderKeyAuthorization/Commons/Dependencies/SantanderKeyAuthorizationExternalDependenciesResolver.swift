import Foundation
import CoreFoundationLib

public protocol SantanderKeyAuthorizationExternalDependenciesResolver: SKAuthorizationExternalDependenciesResolver  {
      func resolve() -> AppConfigRepositoryProtocol
//    func resolve() -> StringLoader
}

public extension SantanderKeyAuthorizationExternalDependenciesResolver {
//    func resolve() -> SKOperativeCoordinator {
//        DefaultSKOperativeCoordinator(dependencies: self)
//    }
}
