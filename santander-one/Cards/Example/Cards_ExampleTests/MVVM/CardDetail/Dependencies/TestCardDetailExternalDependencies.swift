import UI
import Foundation
import CoreDomain
import QuickSetup
import CoreFoundationLib
import CoreTestData
import OpenCombine
import SANLegacyLibrary

@testable import Cards

struct TestCardDetailExternalDependencies: CardDetailExternalDependenciesResolver {
 
    let globalPositionRepository = DefaultGlobalPositionDataRepository()
    let injector: MockDataInjector
    let mockExpensesUseCase = MockGetCardsExpensesCalculationUseCase()
    
    init(injector: MockDataInjector) {
        self.injector = injector
        globalPositionRepository.send(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> CardRepository {
        MockCardRepository(mockDataInjector: injector)
    }
    
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> TimeManager {
        fatalError()
    }
    
    func resolve() -> GetCardsExpensesCalculationUseCase {
        return mockExpensesUseCase
    }
    
    func resolve() -> CardHomeActionModifier {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
    }
    
    func resolve() -> [CardTextColorEntity] {
        []
    }
    
    func moreOperativesCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    
    func resolve() -> CardDetailExternalDependenciesResolver {
        self
    }
    
    func showPANCoordinator() -> BindableCoordinator {
        return ToastCoordinator("")
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository

    }
    
    func activeCardCoordinator() -> BindableCoordinator {
        return ToastCoordinator("")
    }
    
    func resolve() -> GlobalPositionReloader {
        fatalError()
    }

}





