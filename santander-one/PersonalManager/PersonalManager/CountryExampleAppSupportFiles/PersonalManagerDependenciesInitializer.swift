import QuickSetup
import CoreFoundationLib

public final class PersonalManagerDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func registerDependencies() {
        dependencies.register(for: PersonalManagerMainModuleCoordinatorDelegate.self) { _ in
            return PersonalManagerMainModuleCoordinatorImp()
        }
    }
}
