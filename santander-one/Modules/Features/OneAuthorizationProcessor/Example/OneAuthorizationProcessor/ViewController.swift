import QuickSetup
import OneAuthorizationProcessor
import CoreFoundationLib
import UIKit
import CoreTestData

public final class ViewController: UIViewController {
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [
            OneAuthorizationProcessorServiceInjector()
        ]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.presentModule()
    }
    
    private func presentModule() {
        goToAuthorizationProcessor(authorizationId: "", scope: "")
    }
    
    public lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        OneAuthorizationProcessorDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
}

extension ViewController: OneAuthorizationProcessorLauncher {}
