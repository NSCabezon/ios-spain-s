//
//  TestCardTransactionDetailDependencies.swift
//  Cards
//
//  Created by Hernán Villamil on 18/4/22.
//

import Foundation
import CoreTestData
import CoreFoundationLib
@testable import Cards

struct TestCardTransactionDetailDependencies: CardTransactionDetailDependenciesResolver {

    
    var external: CardTransactionDetailExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    let injector: MockDataInjector
    let mockCoordinator = MoMockCardTransactionDetailCoordinator()
    
    init(injector: MockDataInjector, externalDependencies: TestCardTransactionExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        dataBinding
    }
    
    func cardTransactionDetailCoordinator() -> CardTransactionDetailCoordinator {
        mockCoordinator
    }
}
