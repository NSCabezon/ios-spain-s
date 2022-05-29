import CoreFoundationLib
import UI
import SANLegacyLibrary

public protocol InboxHomeModuleCoordinatorDelegate: AnyObject {
    func didSelectOnlineInbox(_ configuration: WebViewConfiguration?)
    func didSelectOffer(_ offer: OfferEntity?)
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
}

public protocol InboxNotificationCoordinatorDelegate: AnyObject {
    func gotoInboxNotification(showHeader: Bool, navigationController: UINavigationController)
}

public protocol InboxHomeCoordinatorProtocol {
    func gotoInboxNotification(showHeader: Bool)
    func didSelectAction(type: InboxActionType)
}

public final class InboxHomeModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: InboxHomeViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension InboxHomeModuleCoordinator {
    private func setupDependencies() {
        let presenter = InboxHomePresenter(dependenciesResolver: self.dependenciesEngine)
        self.dependenciesEngine.register(for: InboxActionDelegate.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: InboxHomePresenterProtocol.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: InboxHomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: InboxHomeViewController.self)
        }
        self.dependenciesEngine.register(for: GetPendingSolicitudesUseCase.self) { dependenciesResolver in
            return GetPendingSolicitudesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: InboxHomeCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetOnlineMessagesWebViewConfigurationUseCase.self) { dependenciesResolver in
            return GetOnlineMessagesWebViewConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetInboxAppConfigUseCase.self) { dependenciesResolver in
            return GetInboxAppConfigUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: RemoveSavedPendingSolicitudesUseCase.self) { dependenciesResolver in
            return RemoveSavedPendingSolicitudesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: InboxHomeViewController.self) { dependenciesResolver in
            var presenter: InboxHomePresenterProtocol = dependenciesResolver.resolve(for: InboxHomePresenterProtocol.self)
            let viewController = InboxHomeViewController(nibName: "Inbox", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension InboxHomeModuleCoordinator: InboxHomeCoordinatorProtocol {
    public func gotoInboxNotification(showHeader: Bool) {
        guard let navigationController = self.navigationController else { return }
        let coordinatorDelegate: InboxNotificationCoordinatorDelegate = self.dependenciesEngine.resolve()
        coordinatorDelegate.gotoInboxNotification(showHeader: showHeader,
                                                  navigationController: navigationController)
    }
    
    public func didSelectAction(type: InboxActionType) {
        guard let modifier = self.dependenciesEngine.resolve(forOptionalType: InboxHomeCoordinatorDelegate.self) else { return }
        modifier.didSelectAction(type: type)
    }
}
