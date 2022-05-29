import CoreFoundationLib
import Localization
import QuickSetup
import SANLegacyLibrary
import CoreTestData
import TransferOperatives

public final class TransferDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    private let mockDataInjector: MockDataInjector
    private let navController: UINavigationController
    
    public init(dependencies: DependenciesInjector) {
        self.dependencies = dependencies
        self.mockDataInjector = MockDataInjector()
        self.navController = UINavigationController()
    }
    
    public init(dependencies: DependenciesInjector, injector: MockDataInjector, navController: UINavigationController) {
        self.dependencies = dependencies
        self.mockDataInjector = injector
        self.navController = navController
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: TransferHomeModuleCoordinatorDelegate.self) { resolver in
            return TransferHomeModuleCoordinatorMock(dependenciesResolver: resolver, navigationController: self.navController)
        }
        self.dependencies.register(for: ContactsEngineProtocol.self) { _ in
            return MockContactsEngine(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: nil, isScaForTransactionsEnabled: false)
        }
        self.dependencies.register(for: ColorsByNameEngine.self) { _ in
            return ColorsByNameEngine()
        }
        self.dependencies.register(for: TransferHomeModifier.self) { resolver in
            return TransferHomeModifier(dependenciesResolver: resolver)
        }
    }
}
