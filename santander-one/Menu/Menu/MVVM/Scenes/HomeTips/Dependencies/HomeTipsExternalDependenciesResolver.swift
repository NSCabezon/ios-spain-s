import Foundation
import CoreFoundationLib
import UI

public protocol HomeTipsExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func publicMenuHomeTipsCoordinator() -> Coordinator
    func publicTipListCoordinator() -> TipListCoordinatorProtocol
}

extension HomeTipsExternalDependenciesResolver {
    public func publicMenuHomeTipsCoordinator() -> Coordinator {
        return DefaultHomeTipsCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
