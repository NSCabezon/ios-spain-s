//
//  TestLoanDetailDependencies.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 24/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreTestData
import CoreFoundationLib
@testable import Loans

struct TestLoanDetailDependencies: LoanDetailDependenciesResolver {
    
    let injector: MockDataInjector
    let external: LoanDetailExternalDependenciesResolver
    let getLoanDetailConfigUseCaseSpy = GetLoanDetailConfigUseCaseSpy()
    let getLoanDetailUseCaseSpy = GetLoanDetailUseCaseSpy()
    
    let coordinatorSpy = LoanDetailCoordinatorSpy()
    let dataBinding: DataBinding
    
    init(injector: MockDataInjector, externalDependencies: TestLoanDetailExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
        self.dataBinding = DataBindingObject()
    }
    
    func resolve() -> DataBinding {
        return self.dataBinding
    }
    
    func resolve() -> LoanDetailCoordinator {
        return self.coordinatorSpy
    }
    
    func resolve() -> GetLoanDetailConfigUseCase {
        return self.getLoanDetailConfigUseCaseSpy
    }
    
    func getDetailSpy() {
        return
    }
}
