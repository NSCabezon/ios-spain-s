
import Foundation
import UI
import CoreFoundationLib
import CoreDomain

protocol SKAuthorizationCoordinator: BindableCoordinator {}

final class DefaultSKAuthorizationCoordinator: SKAuthorizationCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKAuthorizationExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKAuthorizationExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSKAuthorizationCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }

    func dismiss() { 
        navigationController?.popToRootViewController(animated: false)
    }
}

private extension DefaultSKAuthorizationCoordinator {
    struct Dependency: SKAuthorizationDependenciesResolver {
        let dependencies: SKAuthorizationExternalDependenciesResolver
        let coordinator: SKAuthorizationCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKAuthorizationExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKAuthorizationCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
