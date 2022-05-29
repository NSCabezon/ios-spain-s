import UIKit
import QuickSetup
import Inbox
import CoreFoundationLib
import CoreTestData

class ViewController: UIViewController {
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [InboxServiceInjector()]
    }
    
    private func presentModule() {
        let navigationController = UINavigationController()
        let coordinator = InboxModuleCoordinator(dependenciesResolver: self.dependenciesResolver, navigationController: navigationController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: {
            coordinator.start(.home)
        })
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        InboxDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
	
	@IBAction func buzonLinkButton(_ sender: UIButton) {
		self.presentModule()
	}
	
	@IBAction func notificacionesLinkButton(_ sender: UIButton) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false) {
            let coordinator = InboxHomeModuleCoordinator(dependenciesResolver: self.dependenciesResolver,
                                                           navigationController: self.navigationController)
            coordinator.gotoInboxNotification(showHeader: true)
        }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
