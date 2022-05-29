
import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKBiometricsDependenciesResolver {
    var external: SKBiometricsExternalDependenciesResolver { get }
    func resolve() -> SKBiometricsViewModel
    func resolve() -> SKBiometricsViewController
    func resolve() -> SKOperative
    func resolve() -> DataBinding
}

extension SKBiometricsDependenciesResolver {
    
    func resolve() -> SKBiometricsViewController {
        return SKBiometricsViewController(dependencies: self)
    }
    
    func resolve() -> SKBiometricsViewModel {
        return SKBiometricsViewModel(dependencies: self)
    }
}

struct SKBiometricsDependency: SKBiometricsDependenciesResolver {
    let dependencies: SKBiometricsExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: SKOperativeCoordinator
    let operative: SKOperative
    
    var external: SKBiometricsExternalDependenciesResolver {
        return dependencies
    }
    
    func resolve() -> SKOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> SKOperative {
        return operative
    }
}
