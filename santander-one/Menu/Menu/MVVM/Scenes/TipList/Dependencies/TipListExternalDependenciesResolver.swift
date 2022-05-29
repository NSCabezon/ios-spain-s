import Foundation
import CoreFoundationLib
import UI

public protocol TipListExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func publicTipListCoordinator() -> Coordinator
    func publicTipListCoordinator() -> TipListCoordinatorProtocol
}

extension TipListExternalDependenciesResolver {
    public func publicTipListCoordinator() -> Coordinator {
        return DefaultTipListCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
    
    public func publicTipListCoordinator() -> TipListCoordinatorProtocol {
        return DefaultTipListCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
