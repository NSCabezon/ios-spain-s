import UI
import CoreFoundationLib
import SANLegacyLibrary

protocol WithholdingCoordinatorProtocol {
    func didSelectDismiss()
}

final class WithholdingCoordinator: ModuleCoordinator {
    
    private let dependenciesEngine: DependenciesDefault
    public weak var navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        self.navigationController?.present(dependenciesEngine.resolve(for: WithholdingViewController.self), animated: false)
    }
    
    // MARK: - Navigation actions
    
    func dismiss() {
        self.navigationController?.dismiss(animated: false)
    }
    
    private func setupDependencies() {
        
        self.dependenciesEngine.register(for: WithholdingPresenterProtocol.self) { dependenciesResolver in
            return WithholdingPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: WithholdingCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: WithholdingViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: WithholdingViewController.self)
        }
        
        self.dependenciesEngine.register(for: GetWithholdingUseCase.self) { dependenciesResolver in
            return GetWithholdingUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: WithholdingViewController.self) { dependenciesResolver in
            let presenter: WithholdingPresenterProtocol = dependenciesResolver.resolve(for: WithholdingPresenterProtocol.self)
            let viewController = WithholdingViewController(nibName: "WithholdingViewController", bundle: Bundle.module, presenter: presenter)
            viewController.modalPresentationStyle = .overCurrentContext
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: WithholdingCoordinator.self) { _ in
            return self
        }
    }
}

extension WithholdingCoordinator: WithholdingCoordinatorProtocol {
    func didSelectDismiss() {
        dismiss()
    }
}
