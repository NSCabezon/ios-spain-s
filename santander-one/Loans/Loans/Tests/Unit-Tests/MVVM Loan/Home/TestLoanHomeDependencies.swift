//
//  DependenciesMock.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 11/6/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//
import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Loans

struct TestLoanHomeDependencies: LoanHomeDependenciesResolver {
    let injector: MockDataInjector
    let external: LoanHomeExternalDependenciesResolver

    init(injector: MockDataInjector, externalDependencies: TestExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> LoanFilterOutsider {
        MockLoanFilterOutsider()
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> LoanHomeCoordinator {
        fatalError()
    }
}
