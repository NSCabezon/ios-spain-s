import CoreFoundationLib
import UI

public protocol ATMExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func publicMenuATMHomeCoordinator() -> Coordinator
}

extension ATMExternalDependenciesResolver {
    public func publicMenuATMHomeCoordinator() -> Coordinator {
        return DefaultAtmCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
