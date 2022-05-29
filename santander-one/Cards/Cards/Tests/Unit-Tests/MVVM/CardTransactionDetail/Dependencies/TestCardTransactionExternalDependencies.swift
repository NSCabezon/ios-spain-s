//
//  TestExternalDependencies.swift
//  Cards
//
//  Created by Hernán Villamil on 18/4/22.
//

import UI
import Foundation
import CoreDomain
import CoreFoundationLib
import CoreTestData
import OpenCombine
@testable import Cards

struct TestCardTransactionExternalDependencies: CardTransactionDetailExternalDependenciesResolver {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    let coreDependencies = DefaultCoreDependencies()
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector
                                                                            .mockDataProvider
                                                                            .gpData
                                                                            .getGlobalPositionMock)
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func globalSearchCoordinator() -> Coordinator {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
    
    func resolve() -> CoreDependencies {
        coreDependencies
    }
    
    func resolve() -> CardRepository {
        MockCardRepository(mockDataInjector: injector)
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        fatalError()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        globalPositionRepository
    }
    
    func resolve() -> PullOffersInterpreter {
        return PullOffersInterpreterMock()
    }
    
    func resolve() -> LocalAppConfig {
        LocalAppConfigMock()
    }
    
    func resolve() -> EngineInterface {
        fatalError()
    }
    
    func resolve() -> TimeManager {
        TimeManagerMock()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func resolve() -> FirstFeeInfoEasyPayReactiveUseCase {
        fatalError()
    }
    
    func shoppingMapCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver {
        fatalError()
    }
}
