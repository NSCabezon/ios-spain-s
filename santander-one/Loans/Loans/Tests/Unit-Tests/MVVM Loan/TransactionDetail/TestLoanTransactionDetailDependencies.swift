//
//  TestLoanTransactionDetailDependencies.swift
//  Loans
//
//  Created by alvola on 9/3/22.
//
import UI
import Foundation
import CoreTestData
import CoreFoundationLib
import CoreDomain
@testable import Loans

struct TestLoanTransactionDetailDependencies: LoanTransactionDetailDependenciesResolver {
    
    let injector: MockDataInjector
    var external: LoanTransactionDetailExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    
    init(injector: MockDataInjector, externalDependencies: TestLoanTransactionDetailExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> CoreDependencies {
        DefaultCoreDependencies()
    }
    
    func resolve() -> LoanTransactionDetailCoordinator {
        DefaultLoanTransactionDetailCoordinator(dependencies: self.external,
                                                navigationController: external.resolve())
    }

    func resolve() -> DataBinding {
        self.dataBinding
    }
}
