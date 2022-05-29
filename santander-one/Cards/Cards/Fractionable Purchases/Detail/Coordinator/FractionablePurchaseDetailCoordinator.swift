import UI
import CoreFoundationLib

protocol FractionablePurchaseDetailCoordinatorProtocol {
    func dismiss()
}

public final class FractionablePurchaseDetailCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: FractionablePurchaseDetailViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

extension FractionablePurchaseDetailCoordinator: FractionablePurchaseDetailCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension FractionablePurchaseDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: FractionablePurchaseDetailCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: FractionablePurchaseDetailPresenterProtocol.self) { resolver in
            return FractionablePurchaseDetailPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FractionablePurchaseDetailViewController.self) { resolver in
            var presenter = resolver.resolve(for: FractionablePurchaseDetailPresenterProtocol.self)
            let viewController = FractionablePurchaseDetailViewController(
                dependenciesResolver: resolver,
                presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetFractionablePurchaseDetailUseCase.self) { resolver in
            return GetFractionablePurchaseDetailUseCase(dependenciesResolver: resolver)
        }
    }
}
