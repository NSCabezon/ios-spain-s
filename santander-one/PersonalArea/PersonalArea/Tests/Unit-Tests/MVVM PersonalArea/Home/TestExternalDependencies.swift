//
//  TestExternalDependencies.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 20/4/22.
//

import Foundation
import UI
import CoreDomain
import CoreTestData
import CoreFoundationLib
@testable import PersonalArea

struct TestExternalDependencies: PersonalAreaHomeExternalDependenciesResolver {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    let oldDependenciesResolver: DependenciesResolver
    
    init(injector: MockDataInjector, oldDependenciesResolver: DependenciesResolver) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
        self.oldDependenciesResolver = oldDependenciesResolver
    }
    
    func resolve() -> AppRepositoryProtocol {
        return AppRepositoryMock()
    }
    
    func resolve() -> LocalAppConfig {
        return LocalAppConfigMock()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func personalAreaBasicInfoCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func personalAreaConfigurationCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func personalAreaSecurityCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func personalAreaPGPersonalizationCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func personalAreaDigitalProfileCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func personalAreaCustomActionCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> PersonalAreaRepository {
        return MockPersonalAreaRepository()
    }
    
    func resolve() -> ReactivePullOffersRepository {
        return MockReactivePullOffersRepository()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        return MockGetCandidateOfferUseCase()
    }
    
    func resolve() -> GetPersonalAreaHomeConfigurationUseCase {
        return MockGetPersonalAreaHomeConfigurationUseCase(mockDataInjector: injector)
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        return oldDependenciesResolver
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> EmmaTrackEventListProtocol {
        return EmmaTrackEventListMock()
    }
    
    func resolve() -> GetHomeUserPreferencesUseCase {
        return MockGetHomeUserPreferencesUseCase()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
}

final class EmmaTrackEventListMock: EmmaTrackEventListProtocol {
    var globalPositionEventID: String = ""
    var accountsEventID: String = ""
    var cardsEventID: String = ""
    var transfersEventID: String = ""
    var billAndTaxesEventID: String = ""
    var personalAreaEventID: String = ""
    var managerEventID: String = ""
    var customerServiceEventID: String = ""
}
