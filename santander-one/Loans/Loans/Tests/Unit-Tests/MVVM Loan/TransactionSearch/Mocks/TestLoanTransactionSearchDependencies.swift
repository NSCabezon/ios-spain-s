//
//  TestLoanTransactionSearchDependencies.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta on 21/3/23.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Loans

struct TestLoanTransactionSearchDependencies: LoanTransactionSearchDependenciesResolver {
    
    let injector: MockDataInjector
    let external: LoanTransactionSearchExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinatorSpy = LoanTransactionSearchCoordinatorSpy()

    init(injector: MockDataInjector, externalDependencies: TestLoanTransactionSearchExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
        self.dataBinding = DataBindingObject()
    }

    func resolve() -> DataBinding {
        return self.dataBinding
    }
    
    func resolve() -> LoanTransactionSearchCoordinator {
        return coordinatorSpy
    }
}
