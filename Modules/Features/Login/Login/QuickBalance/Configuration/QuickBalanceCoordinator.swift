import CoreFoundationLib
import UI
import SANLibraryV3
import LoginCommon

public class QuickBalanceCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: QuickBalanceViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: QuickBalancePresenterProtocol.self) { dependenciesResolver in
            return QuickBalancePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: QuickBalanceViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: QuickBalanceViewController.self)
        }
        self.dependenciesEngine.register(for: QuickBalanceViewController.self) { dependenciesResolver in
            let presenter: QuickBalancePresenterProtocol = dependenciesResolver.resolve(for: QuickBalancePresenterProtocol.self)
            let viewController = QuickBalanceViewController(nibName: "QuickBalanceViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: QuickBalanceLoginUseCase.self) { dependenciesResolver in
            return QuickBalanceLoginUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: QuickBalanceAccountUseCase.self) { dependenciesResolver in
            return QuickBalanceAccountUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: PullOfferTutorialCandidatesUseCase.self) { dependenciesResolver in
            return PullOfferTutorialCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
