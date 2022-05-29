import CoreFoundationLib
import UI

protocol AviosDetailCoordinatorProtocol {
    func dismiss()
}

final class AviosDetailCoordinator: ModuleCoordinator, AviosDetailCoordinatorProtocol {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    weak var navigationController: UINavigationController?

    init(resolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = navigationController
        self.dependenciesEngine.register(for: GetAviosDetailInfoUseCaseAlias.self) { dependenciesResolver in
            return GetAviosDetailInfoUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AviosDetailCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: AviosDetailPresenterProtocol.self) { dependenciesResolver in
            return AviosDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AviosDetailViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: AviosDetailViewController.self)
        }
        self.dependenciesEngine.register(for: AviosDetailViewController.self) { dependenciesResolver in
            var presenter: AviosDetailPresenterProtocol = dependenciesResolver.resolve()
            let viewController: AviosDetailViewController = AviosDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func start() {
        let view = dependenciesEngine.resolve(for: AviosDetailViewController.self)
        self.navigationController?.blockingPushViewController(view, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
