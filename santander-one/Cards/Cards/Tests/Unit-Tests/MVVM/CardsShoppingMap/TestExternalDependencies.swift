//
//  TestExternalDependencies.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import Foundation
import CoreDomain
import CoreFoundationLib
import CoreTestData
import OpenCombine
@testable import Cards

struct TestExternalDependencies: CardShoppingMapExternalDependenciesResolver {
    let injector: MockDataInjector
    
    init(injector: MockDataInjector) {
        self.injector = injector
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
    
    func resolve() -> GetDatedCardMovementsLocationsForShoppingMapUseCase {
        MockGetDatedCardMovementLocationsForShoppingMapUseCase(injector: injector)
    }
    
    func resolve() -> GetMultipleCardMovementLocationsForShoppingMapUseCase {
        MockGetMultipleCardMovementLocationsForShoppingMapUseCase(injector: injector)
    }
    
    func resolve() -> CardRepository {
        MockCardRepository(mockDataInjector: injector)
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
}
