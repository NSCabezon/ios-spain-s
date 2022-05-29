import UI
import CoreFoundationLib

protocol BizumSendAgainCoordinatorProtocol {
    func didSelectSendAgain(_ viewModel: BizumSendAgainOperativeViewModel)
    func didSelectRequestAgain(_ viewModel: BizumSendAgainOperativeViewModel)
    func sendAgainViewDisappear()
}

final class BizumSendAgainCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private var view: BizumSendAgainView?

    init(navigationController: UINavigationController?, dependenciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }

    func start() {
        self.view = self.dependenciesEngine.resolve(for: BizumSendAgainView.self)
        self.view?.load()
    }
}

extension BizumSendAgainCoordinator: BizumSendAgainCoordinatorProtocol {
    func didSelectSendAgain(_ viewModel: BizumSendAgainOperativeViewModel) {
        self.view?.closeWithAnimationAndCompletion {
            self.delegate.goToReuseSendMoney(viewModel.contact, bizumSendMoney: viewModel.bizumSendMoney)
        }
    }

    func didSelectRequestAgain(_ viewModel: BizumSendAgainOperativeViewModel) {
        self.view?.closeWithAnimationAndCompletion {
            self.delegate.goToReuseRequestMoney(viewModel.contact, bizumSendMoney: viewModel.bizumSendMoney)
        }
    }
    
    func sendAgainViewDisappear() {
        self.view?.closeWithoutAnimation()
    }
}

private extension BizumSendAgainCoordinator {
    var delegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }

    func setupDependencies() {
        self.dependenciesEngine.register(for: BizumSendAgainCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: BizumSendAgainPresenterProtocol.self) { dependenciesResolver in
            let presenter = BizumSendAgainPresenter(dependenciesResolver: dependenciesResolver)
            return presenter
        }
        self.dependenciesEngine.register(for: BizumSendAgainView.self) { dependenciesResolver in
            var presenter: BizumSendAgainPresenterProtocol = dependenciesResolver.resolve()
            let viewController = BizumSendAgainView(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
