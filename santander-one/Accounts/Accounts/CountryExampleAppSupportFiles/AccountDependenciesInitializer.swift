import CoreFoundationLib
import Localization
import QuickSetup

public final class AccountDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: AccountsHomeCoordinatorDelegate.self) { _ in
            return AccountsHomeModuleCoordinatorMock()
        }
        self.dependencies.register(for: AccountsHomeConfiguration.self) { _ in
            return AccountsHomeConfiguration(selectedAccount: nil, isScaForTransactionsEnabled: true)
        }
        self.dependencies.register(for: AccountTransactionDetailCoordinatorDelegate.self) { _ in
            return AccountsTransactionDetailCoordinatorMock()
        }
        self.dependencies.register(for: GetAccountHomeActionUseCaseProtocol.self) { resolver  in
            return GetCoreAccountHomeActionUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetAccountOtherOperativesActionUseCaseProtocol.self) { resolver  in
            return GetCoreAccountOtherOperativesActionUseCase(dependenciesResolver: resolver)
        }
    }
}
