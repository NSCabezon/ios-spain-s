import CoreFoundationLib
import CoreTestData
import QuickSetup
import UIKit
import CoreDomain
import UI

public final class FeatureFlagsDependenciesInitializer: ModuleDependenciesInitializer, FeatureFlagsExternalDependenciesResolver {
    
    private let dependencies: DependenciesInjector
    private weak var navigationController: UINavigationController?
    
    public init(dependencies: DependenciesInjector, navigationController: UINavigationController) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    public func registerDependencies() {
        dependencies.register(for: FeatureFlagsRepository.self) { _ in
            return self.resolve()
        }
        dependencies.register(for: BooleanFeatureFlag.self) { _ in
            return self.resolve()
        }
    }
}

extension FeatureFlagsDependenciesInitializer {
    
    public func resolve() -> UINavigationController {
        return navigationController ?? UINavigationController()
    }
    
    public func resolve() -> FeatureFlagsRepository {
        return DefaultFeatureFlagsRepository(features: CoreFeatureFlag.allCases)
    }
    
    public func resolve() -> AppConfigRepositoryProtocol {
        return AppConfigRepositoryMock()
    }
    
    public func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    public func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
}

public final class FeatureFlagsServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {}
}
