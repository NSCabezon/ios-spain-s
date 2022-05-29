//
//  TestPersonalAreaHomeDependencies.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 20/4/22.
//
import Foundation
import UI
import CoreFoundationLib
import CoreTestData
@testable import PersonalArea

struct TestPersonalAreaHomeDependencies: PersonalAreaHomeDependenciesResolver {
    let injector: MockDataInjector
    let external: PersonalAreaHomeExternalDependenciesResolver

    init(injector: MockDataInjector, externalDependencies: TestExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> PersonalAreaHomeCoordinator {
        fatalError()
    }
}
