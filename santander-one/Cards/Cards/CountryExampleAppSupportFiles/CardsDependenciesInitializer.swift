import CoreFoundationLib
import CoreTestData
@testable import Cards

public final class CardsDependenciesInitializer {
    
    private let dependencies: DependenciesInjector
    private let mockDataInjector: MockDataInjector
    
    public init(dependencies: DependenciesInjector, mockDataInjector: MockDataInjector) {
        self.dependencies = dependencies
        self.mockDataInjector = mockDataInjector
    }
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.mockDataInjector = MockDataInjector()
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(self.mockDataInjector.mockDataProvider.gpData)
        }
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: CardsHomeModuleCoordinatorDelegate.self, with: { _ in
            return ModuleCoordinatorDelegateMock()
        })
        self.dependencies.register(for: HistoricExtractOperativeData.self, with: { dependenciesResolver in
            let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
            guard let card = globalPosition.cards.first else {
                return dependenciesResolver.resolve()
            }
            return HistoricExtractOperativeData(card)
        })
        self.dependencies.register(for: CardHomeActionModifier.self) { dependencies in
            return CardHomeActionModifier(dependenciesResolver: dependencies)
        }
        self.dependencies.register(for: CardsHomeConfiguration.self) { dependenciesResolver in
            let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
            return CardsHomeConfiguration(selectedCard: globalPosition.cards[0])
        }
        self.dependencies.register(for: [CardTextColorEntity].self) { _ in
            return []
        }
    }
}
