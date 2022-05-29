import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKAuthorizationDependenciesResolver {
    var external: SKAuthorizationExternalDependenciesResolver { get }
    func resolve() -> SKAuthorizationViewModel
    func resolve() -> SKAuthorizationViewController
    func resolve() -> SKAuthorizationCoordinator
    func resolve() -> DataBinding
}

extension SKAuthorizationDependenciesResolver {
    func resolve() -> SKAuthorizationViewController {
        return SKAuthorizationViewController(dependencies: self)
    }
    
    func resolve() -> SKAuthorizationViewModel {
        return SKAuthorizationViewModel(dependencies: self)
    }
}
