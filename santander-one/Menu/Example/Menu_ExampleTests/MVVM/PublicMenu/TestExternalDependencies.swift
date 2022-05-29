//
//  TestExternalDependencies.swift
//  Menu_ExampleTests
//
//  Created by alvola on 21/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CoreTestData
import CoreFoundationLib
import CoreDomain
import UI
@testable import Menu

class TestExternalDependencies: PublicMenuExternalDependenciesResolver {
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
    
    func resolve() -> ReactivePullOffersInterpreter {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> ReactivePullOffersConfigRepository {
        fatalError()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> PublicMenuActionsRepository {
        fatalError()
    }
    
    func resolveSideMenuNavigationController() -> UINavigationController {
        fatalError()
    }
    
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    public var injector: MockDataInjector
    
    private var homeTipsRepositoryMock: HomeTipsRepository
    
    init(injector: MockDataInjector, homeTipsRepository: HomeTipsRepository = MockHomeTipsRepository(0)) {
        self.injector = injector
        self.homeTipsRepositoryMock = homeTipsRepository
    }
    
    func publicMenuATMHomeCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuStockholdersCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuOurProductsCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuHomeTipsCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> PublicMenuRepository {
        return PublicMenuRepositoryMock()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> SegmentedUserRepository {
        return injector.mockDataProvider.commercialSegment ?? MockSegmentedUserRepository(mockDataInjector: injector)
    }
    
    func resolve() -> HomeTipsRepository {
        return homeTipsRepositoryMock
    }
    
    func resolve() -> PublicMenuCoordinatorDelegate {
        fatalError()
    }
    
    func resolve() -> PublicMenuToggleOutsider {
        fatalError()
    }
}
