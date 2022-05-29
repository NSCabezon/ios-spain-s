import CoreFoundationLib
import UI
import SANLegacyLibrary

public class WithPersonalManagerModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    weak var coordinator: ModuleSectionInternalCoordinator?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let personalManagerViewController = self.dependenciesEngine.resolve(for: PersonalManagerViewController.self)
        if let globalPositionVC = navigationController?.viewControllers.first {
            navigationController?.setViewControllers([globalPositionVC, personalManagerViewController], animated: true)
        } else {
            navigationController?.setViewControllers([personalManagerViewController], animated: false)
        }
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: PersonalManagerPresenterProtocols.self) { dependenciesResolver in
            return PersonalManagerPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: PersonalManagerViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: PersonalManagerViewController.self)
        }
        self.dependenciesEngine.register(for: GetManagersInfoUseCase.self) { dependenciesResolver in
            return GetManagersInfoUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SingleSignOnUseCase.self) { _ in
            return SingleSignOnUseCase()
        }
        self.dependenciesEngine.register(for: GetManagerWallDataUseCase.self) { _ in
            return GetManagerWallDataUseCase()
        }
        self.dependenciesEngine.register(for: GetManagerNotificationUseCase.self) { dependenciesResolver in
            return GetManagerNotificationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetManagerWallStateUseCase.self) { dependenciesResolver in
            return GetManagerWallStateUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetClick2CallUseCase.self) { dependenciesResolver in
            return GetClick2CallUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: PersonalManagerViewController.self) { [weak self] dependenciesResolver in
            var presenter: PersonalManagerPresenterProtocols = dependenciesResolver.resolve(for: PersonalManagerPresenterProtocols.self)
            let viewController = PersonalManagerViewController(nibName: "PersonalManager", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            presenter.coordinator = self?.coordinator
            return viewController
        }
    }
}

extension WithPersonalManagerModuleCoordinator: ModuleCoordinatorReplacer {
    public func startReplacingCurrent() {
        self.navigationController?.viewControllers.removeLast(1)
        let controller = self.dependenciesEngine.resolve(for: NoPersonalManagerViewController.self)
        self.navigationController?.setViewControllers((self.navigationController?.viewControllers ?? []) + [controller], animated: false)
    }
}
