import CoreFoundationLib
import QuickSetup
import CoreTestData

public final class MenuDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
    public func registerDependencies() {
        self.dependencies.register(for: MenuMainModuleCoordinatorDelegate.self) { _ in
            return MenuMainModuleCoordinatorMock()
        }
        self.dependencies.register(for: AtmCoordinatorDelegate.self) { _ in
            return MenuAtmCoordinatorMock()
        }
        self.dependencies.register(for: GetAccountsUseCase.self) { dependenciesResolver in
            return GetAccountsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: CardFinanceableTransactionConfiguration.self) { _ in
            return CardFinanceableTransactionConfiguration(selectedCard: nil)
        }
        self.dependencies.register(for: OldAnalysisAreaCoordinatorDelegate.self) { _ in
            return AnalysisAreaCoordinatorMock()
        }
        self.dependencies.register(for: AccountFinanceableTransactionConfigurationProtocol.self) { _ in
            return AccountFinanceableTransactionConfigurationMock()
        }
        self.dependencies.register(for: PublicMenuCoordinatorDelegate.self) { _ in
            return PublicMenuCoordinatorMock()
        }
    }
}
