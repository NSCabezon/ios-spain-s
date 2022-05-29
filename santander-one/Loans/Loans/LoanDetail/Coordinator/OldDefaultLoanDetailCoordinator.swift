import UI
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

protocol OldLoanDetailCoordinator: BindableCoordinator {
    func doShare(for shareable: Shareable)
    func didSelectMenu()
}

final class OldDefaultLoanDetailCoordinator {
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var dependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: LoanDetailExternalDependenciesResolver

    init(dependencies: LoanDetailExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.externalDependencies = dependencies
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        guard let loan: LoanRepresentable = dataBinding.get(), let detail: LoanDetailRepresentable = dataBinding.get() else { return }
        // Legacy implementation of passing data
        self.dependenciesEngine.register(for: OldLoanDetailConfiguration.self) { _ in
            return OldLoanDetailConfiguration(loan: LoanEntity(loan), loanDetail: LoanDetailEntity(detail))
        }
        self.navigationController?.blockingPushViewController(dependenciesEngine.resolve(for: OldLoanDetailViewController.self), animated: true)
    }
}

private extension OldDefaultLoanDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: OldLoanDetailPresenterProtocol.self) { dependenciesResolver in
            return OldLoanDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: OldLoanDetailViewController.self) { dependenciesResolver in
            let presenter: OldLoanDetailPresenterProtocol = dependenciesResolver.resolve(for: OldLoanDetailPresenterProtocol.self)
            let viewController = OldLoanDetailViewController(nibName: "OldLoanDetailViewController", bundle: Bundle.module, presenter: presenter, dependenciesResolver: self.dependenciesEngine)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: OldLoanDetailCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
    }
}

extension OldDefaultLoanDetailCoordinator: OldLoanDetailCoordinator {
    
    func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandler = self.dependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandler.doShare(for: shareable, in: controller)
    }
    
    func didSelectMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
}

private extension OldDefaultLoanDetailCoordinator {
    struct Dependency: OldLoanDetailDependenciesResolver {
        let dependencies: LoanDetailExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: LoanDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
