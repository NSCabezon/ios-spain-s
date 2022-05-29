import Foundation
import CoreDomain
import CoreFoundationLib
import UI

public protocol CardShowPANCoordinator: BindableCoordinator { }

final class DefaultCardShowPANCoordinator: CardShowPANCoordinator {
    public var onFinish: (() -> Void)?
    public var dataBinding: DataBinding = DataBindingObject()
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    private let dependencies: CardCommonExternalDependenciesResolver
    
    public init(dependencies: CardCommonExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func start() {
        Toast.show("Show PAN")
    }
}
