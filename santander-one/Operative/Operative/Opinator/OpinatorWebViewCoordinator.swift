import CoreFoundationLib
import UI

public protocol OpinatorWebViewCoordinatorDependenciesResolver {
    func resolve() -> OperativeContainerCoordinatorDelegate
}

public final class OpinatorWebViewCoordinator: BindableCoordinator {
    private weak var operativeContainerCoordinatorDelegate: OperativeContainerCoordinatorDelegate?
    public var dataBinding: DataBinding = DataBindingObject()
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    
    public init(dependencies: OpinatorWebViewCoordinatorDependenciesResolver) {
        self.operativeContainerCoordinatorDelegate = dependencies.resolve()
    }
    
    public func start() {
        guard let info: OpinatorInfoRepresentable = dataBinding.get() else { return }
        operativeContainerCoordinatorDelegate?.handleGiveUpOpinator(info) { [weak self] in
            self?.onFinish?()
        }
    }
}
