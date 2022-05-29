import CoreFoundationLib
import UI

public final class GPCustomizationCoordinator: ModuleCoordinator {
    private let engine: DependenciesDefault
    public weak var navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.engine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    public func start() {
        let controller = engine.resolve(for: GPCustomizationViewProtocol.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.engine.register(for: GPCustomizationPresenterProtocol.self) { dependenciesResolver in
            return GPCustomizationPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.engine.register(for: GPCustomizationViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: GPCustomizationViewController.self)
        }
        
        self.engine.register(for: GPCustomizationViewProtocol.self) { dependenciesResolver in
            var presenter: GPCustomizationPresenterProtocol = dependenciesResolver.resolve(for: GPCustomizationPresenterProtocol.self)
            let viewController = GPCustomizationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }

        self.engine.register(for: GetGlobalPositionUseCase.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }

        self.engine.register(for: ChangeAccountAliasUseCase.self) { _ in
            return ChangeAccountAliasUseCase()
        }

        self.engine.register(for: ChangeCardAliasUseCase.self) { _ in
            return ChangeCardAliasUseCase()
        }
        
        self.engine.register(for: UpdateUserPrefContentUseCase.self) { _ in
            return UpdateUserPrefContentUseCase()
        }
        
        self.engine.register(for: GetGPCustomizationConfigurationUseCase.self) { _ in
            return GetGPCustomizationConfigurationUseCase()
        }
    }
}
