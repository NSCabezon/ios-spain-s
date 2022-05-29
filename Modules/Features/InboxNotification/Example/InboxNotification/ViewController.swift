import UIKit
import QuickSetup
import Inbox
import CoreFoundationLib
import SANLibraryV3
import InboxNotification

class ViewController: UIViewController {
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager()
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
    
    private lazy var inboxHomeCoordinator: InboxHomeModuleCoordinator = {
        let homeCoordinator = InboxHomeModuleCoordinator(dependenciesResolver: self.dependenciesResolver,
                                                         navigationController: self.navigationController)
        return homeCoordinator
    }()
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        
        let defaultResolver = DependenciesDefault()

        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            return QuickSetup.shared.managersProvider
        }
        
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOfferInterpreterMock()
        }

        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return QuickSetup.shared.getGlobalPosition()!
        }
        
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        
        defaultResolver.register(for: InboxNotificationCoordinatorDelegate.self) { _  in
            return self
        }
        
        defaultResolver.register(for: InboxHomeModuleCoordinatorDelegate.self) { _  in
            return self
        }
        
        defaultResolver.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        
        defaultResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryMock()
        }

        defaultResolver.register(for: APPNotificationManagerBridgeProtocol.self) { _ in
            return self
        }
        
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentModule()
    }
}

private extension ViewController {
    func presentModule() {
        QuickSetup.shared.doLogin(withUser: .demo)
        inboxHomeCoordinator.start()
    }
}
    
extension ViewController: InboxNotificationCoordinatorDelegate {
    func gotoInboxNotification(showHeader: Bool, navigationController: UINavigationController) {
        let inbox = InboxNotificationCoordinator(dependenciesResolver: self.dependenciesResolver)
        inbox.gotoInboxNotification(showHeader: showHeader, navigationController: navigationController)
    }
}

extension ViewController: InboxHomeModuleCoordinatorDelegate {
    func didSelectOnlineInbox(_ configuration: WebViewConfiguration?) {}
    
    func didSelectOffer(_ offer: OfferEntity?) {}
    
    func didSelectMenu() {}
    
    func didSelectDismiss() {}
    
    func didSelectNotification(_ notification: PushNotificationConformable) {}
    
    func didSelectSearch() {}
    
    func didSelectSantanderKey() {}
}

extension ViewController: APPNotificationManagerBridgeProtocol {
    func getSalesforceInstance() -> BridgedSalesforceProtocol? {
        return MockSalesForce()
    }
}
