import CoreFoundationLib
import UI

public protocol StockholdersCoordinatorProtocol: AnyObject {
    func close()
    func showDialog()
}

public final class DefaultStockholdersCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var dependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: StockholdersExternalDependenciesResolver
    
    public var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    public var onFinish: (() -> Void)?
    
    public init(dependenciesResolver: StockholdersExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: StockholdersPresenterProtocol.self) { dependenciesResolver in
            return StockholdersPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: StockholdersViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: StockholdersPresenterProtocol.self)
            let viewController = StockholdersViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: LoadPublicProductsUseCase.self) { dependenciesResolver in
            return LoadPublicProductsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: StockholdersCoordinatorProtocol.self) { _ in
            return self
        }
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: StockholdersViewProtocol.self)
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            self.navigationController?.popToRootViewController(animated: false)
        }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

extension DefaultStockholdersCoordinator: StockholdersCoordinatorProtocol {
    public func close() {
        navigationController?.popViewController(animated: true)
    }
    
    public func showDialog() {
        let coordinatorDelegate = self.dependenciesEngine.resolve(for: PublicMenuCoordinatorDelegate.self)
        coordinatorDelegate.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: localized("generic_error_alert_title"),
            body: localized("generic_error_alert_text"), acceptAction: { [weak self] in
            self?.close()
        }, cancelAction: nil)
    }
}

extension DefaultStockholdersCoordinator: StockholdersCoordinator { }

private extension DefaultStockholdersCoordinator {
    struct Dependency: StockholdersDependenciesResolver {
        let dependencies: StockholdersExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: StockholdersExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
