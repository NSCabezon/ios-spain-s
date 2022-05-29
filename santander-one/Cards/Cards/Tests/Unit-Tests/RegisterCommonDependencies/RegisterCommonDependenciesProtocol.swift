import CoreFoundationLib
import CoreTestData
import SANLegacyLibrary
@testable import Cards

protocol RegisterCommonDependenciesProtocol {
    var mockDataInjector: MockDataInjector { get }
    var dependenciesResolver: DependenciesDefault { get }
    func setupCommonsDependencies()
}

extension RegisterCommonDependenciesProtocol {
    func setupCommonsDependencies() {
        dependenciesResolver.register(for: UseCaseHandler.self) { _ in
            UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            AppRepositoryMock()
        }
        dependenciesResolver.register(for: BaseURLProvider.self) { _ in
            BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        dependenciesResolver.register(for: TrackerManager.self) { _ in
            TrackerManagerMock()
        }
        dependenciesResolver.register(for: TimeManager.self) { _ in
            TimeManagerMock()
        }
        dependenciesResolver.register(for: StringLoader.self) { _ in
            StringLoaderMock()
        }
        dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        CardsDependenciesInitializer(dependencies: self.dependenciesResolver,
                                     mockDataInjector: mockDataInjector).registerDependencies()
    }
}
