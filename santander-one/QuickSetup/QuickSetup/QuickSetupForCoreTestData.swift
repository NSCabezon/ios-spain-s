import SANLegacyLibrary
import CoreTestData
import CoreFoundationLib

/// Helper class that uses mock files or objects to inject services responses in a example app.
///

public class QuickSetupForCoreTestData {
    public var mockDataInjector = MockDataInjector()
    public init() {}
}

extension QuickSetupForCoreTestData: ServicesProvider {
    public func registerDependencies(in dependencies: DependenciesInjector & DependenciesResolver) {
        let services = dependencies.resolve(forOptionalType: [CustomServiceInjector].self)
        services?.forEach { serviceInjector in
            serviceInjector.inject(injector: self.mockDataInjector)
        }
        dependencies.register(for: BSANManagersProvider.self) { _ in
            return MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return self.getGlobalPosition()
        }
        dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
        }
        MockRepositoryManager(dependencies: dependencies, mockDataInjector: mockDataInjector).registerDependencies()
        
        MockDataRepositories(mockDataInjector: mockDataInjector, dependencies: dependencies)
            .registerDependencies()
    }
}

private extension QuickSetupForCoreTestData {
    func getGlobalPosition() -> GlobalPositionRepresentable {
        return GlobalPositionMock(
            self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
        )
    }

}
