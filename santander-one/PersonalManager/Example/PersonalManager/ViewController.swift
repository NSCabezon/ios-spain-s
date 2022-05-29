import UIKit
import QuickSetup
import PersonalManager
import CoreFoundationLib
import CoreTestData

class ViewController: UIViewController {
    
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [PersonalManagerServiceInjector()]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {

        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = PersonalManagerModuleCoordinator(dependenciesResolver: dependenciesResolver,
                                                           navigationController: navigationController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: {
            coordinator.start(.withoutManager)
        })

    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        PersonalManagerDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
}
