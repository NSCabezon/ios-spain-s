//
//  TestCardDetailDependencies.swift
//  SantanderTests
//
//  Created by Gloria Cano López on 10/3/22.
//

import Foundation
import CoreTestData
import CoreFoundationLib
import UnitTestCommons
@testable import Cards

struct TestCardDetailDependencies: CardDetailDependenciesResolver {
    var external: CardDetailExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    let injector: MockDataInjector
    
    init(injector: MockDataInjector, externalDependencies: TestCardDetailExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> CardDetailCoordinator {
        return DefaultCardDetailCoordinator(dependencies: external, navigationController: UINavigationController())
    }
    
    func resolve() -> DataBinding {
        dataBinding
    }
    
    func resolve() -> GetCardDetailConfigurationUseCase {
        return DefaultGetCardDetailConfigurationUseCase()
    }
    
    func resolve() -> GetCardDetailUseCase {
        return DefaultGetCardDetailUseCase(dependencies: self)
    }
}
