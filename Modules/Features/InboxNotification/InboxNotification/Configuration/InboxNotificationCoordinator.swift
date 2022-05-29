import CoreFoundationLib
import UI
import Inbox

protocol InboxNotificationCoordinatorProtocol {
    func didSelectNotification(_ notification: PushNotificationConformable)
	func didSelectOffer(_ offer: OfferEntity?)
	func dismissViewController()
	func openMenu()
}

final public class InboxNotificationCoordinator: ModuleCoordinator {
	
	public weak var navigationController: UINavigationController?
	private let dependenciesEngine: DependenciesDefault
	private let coordinatorDelegate: InboxHomeModuleCoordinatorDelegate
    private let notificationDetailCoordinator: InboxNotificationDetailCoordinator
    private var showHeader: Bool = false
	
    public init(dependenciesResolver: DependenciesResolver) {
		self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.coordinatorDelegate = dependenciesEngine.resolve(for: InboxHomeModuleCoordinatorDelegate.self)
        self.notificationDetailCoordinator = InboxNotificationDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController)
		self.setupDependencies()
	}
    
	public func start() {
		let controller = self.dependenciesEngine.resolve(for: InboxNotificationViewController.self)
		self.navigationController?.blockingPushViewController(controller, animated: true)
	}
	
	private func setupDependencies() {
		self.dependenciesEngine.register(for: InboxNotificationPresenterProtocol.self) { dependenciesResolver in
			return InboxNotificationPresenter(dependenciesResolver: dependenciesResolver)
		}
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
		
		self.dependenciesEngine.register(for: InboxNotificationViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: InboxNotificationViewController.self)
        }
		
		self.dependenciesEngine.register(for: InboxNotificationCoordinatorProtocol.self) { _ in
			return self
		}
        
        self.dependenciesEngine.register(for: InboxNotificationDataSourceProtocol.self) { dependenciesResolver in
            return InboxNotificationDataSource(dependencies: dependenciesResolver)
        }
        
		self.dependenciesEngine.register(for: InboxNotificationViewController.self) { dependenciesResolver in
            let presenter: InboxNotificationPresenterProtocol = dependenciesResolver.resolve(for: InboxNotificationPresenterProtocol.self)
            let viewController = InboxNotificationViewController(nibName: "InboxNotificationViewController",
                                                                 bundle: Bundle.module,
                                                                 presenter: presenter,
                                                                 showHeader: self.showHeader)
            presenter.view = viewController
            return viewController
        }
	}
}

extension InboxNotificationCoordinator: InboxNotificationCoordinatorProtocol {
    func didSelectNotification(_ notification: PushNotificationConformable) {
        notificationDetailCoordinator.navigateToPushNotification(notification)
    }
    
    func didSelectOffer(_ offer: OfferEntity?) {
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func dismissViewController() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func openMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
}

extension InboxNotificationCoordinator: InboxNotificationCoordinatorDelegate {
    public func gotoInboxNotification(showHeader: Bool, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.notificationDetailCoordinator.navigationController = navigationController
        self.showHeader = showHeader
        self.start()
    }
}
