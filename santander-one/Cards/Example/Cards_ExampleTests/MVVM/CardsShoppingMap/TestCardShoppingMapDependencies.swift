//
//  TestCardShoppingMapDependencies.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreTestData
import CoreFoundationLib
@testable import Cards

struct TestCardShoppingMapDependencies: CardShoppingMapDependenciesResolver {
    var external: CardShoppingMapExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    let injector: MockDataInjector
    
    init(injector: MockDataInjector, externalDependencies: TestExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> CardShoppingMapCoordinator {
        fatalError()
    }
    
    func resolve() -> DataBinding {
        dataBinding
    }
}
