import QuickSetup
import Account
import CoreFoundationLib
import UIKit
import CoreTestData

public final class ViewController: UIViewController {
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [AccountServiceInjector()]
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        let navigationController = UINavigationController()
        let coordinator = AccountsModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
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
        AccountDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
}
