import UI
import CoreFoundationLib

public protocol HomeTipsCoordinatorProtocol {
    func close()
}

final class DefaultHomeTipsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var dependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: HomeTipsExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var onFinish: (() -> Void)?
    
    init(dependenciesResolver: HomeTipsExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: HomeTipsViewController.self)
        if self.navigationController?.viewControllers.last as? IsStackeable == nil,
           let viewControllers = self.navigationController?.viewControllers,
           viewControllers.count > 1 {
            self.navigationController?.popToRootViewController(animated: false)
        }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension DefaultHomeTipsCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: LoadHomeTipsUseCase.self) { dependenciesResolver in
            return LoadHomeTipsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: HomeTipsCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: HomeTipsPresenterProtocol.self) { dependenciesResolver in
            return HomeTipsPresenter(dependenciesResolver: dependenciesResolver, dependenciesInjector: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: HomeTipsViewController.self) { dependenciesResolver in
            var presenter: HomeTipsPresenterProtocol = dependenciesResolver.resolve(for: HomeTipsPresenterProtocol.self)
            let viewController = HomeTipsViewController(nibName: "HomeTipsViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: TipListCoordinatorProtocol.self) { _ in
            return self.externalDependencies.publicTipListCoordinator()
         }
    }
}

extension DefaultHomeTipsCoordinator: HomeTipsCoordinatorProtocol {
    public func close() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DefaultHomeTipsCoordinator: HomeTipsCoordinator {
    
}

private extension DefaultHomeTipsCoordinator {
    struct Dependency: HomeTipsDependenciesResolver {
        let dependencies: HomeTipsExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: HomeTipsExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
