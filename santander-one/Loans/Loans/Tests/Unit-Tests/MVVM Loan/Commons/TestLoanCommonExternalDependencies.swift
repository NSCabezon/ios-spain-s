//
//  TestLoanCommonExternalDependenciesResolver.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 2/3/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreDomain
import CoreTestData
@testable import Loans

struct TestLoanCommonExternalDependencies: LoanCommonExternalDependenciesResolver {
    let injector: MockDataInjector
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    func resolve() -> LoanReactiveRepository {
        MockLoanRepository(mockDataInjector: injector)
    }
}
