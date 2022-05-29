import CoreFoundationLib
import CoreTestData
import Localization
import QuickSetup
import CoreDomain

public final class OneAuthorizationProcessorDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector & DependenciesResolver
    private let coordinator: OneAuthorizationProcessorMainModuleCoordinatorMock
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.coordinator = OneAuthorizationProcessorMainModuleCoordinatorMock(dependenciesResolver: dependencies)
    }
    
    public func registerDependencies() {
        dependencies.register(for: ChallengesHandlerDelegate.self) { resolver in
            return self.coordinator
        }
        dependencies.register(for: OneAuthorizationProcessorDelegate.self) { resolver in
            return self.coordinator
        }
    }
}

public final class OneAuthorizationProcessorServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(for: \.oapData.authorizeOperation, element: .success(Redirect(uri: "")))
        injector.register(for: \.oapData.challenges, element: .success([MockChallenge.pin]))
        injector.register(for: \.oapData.confirmChallenges, element: .success(()))
    }
}

private struct Redirect: RedirectUriRepresentable {
    let uri: String
}
