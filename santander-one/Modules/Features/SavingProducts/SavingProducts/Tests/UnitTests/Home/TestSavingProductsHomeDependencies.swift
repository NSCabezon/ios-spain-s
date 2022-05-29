//
//  TestSavingProductsHomeDependencies.swift
//  SavingProducts-Unit-Tests
//
//  Created by Adrian Escriche Martin on 4/4/22.
//
import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import SavingProducts

struct TestSavingProductsHomeDependencies: SavingsHomeDependenciesResolver {
    let injector: MockDataInjector
    let external: SavingsHomeExternalDependenciesResolver
    
    init(injector: MockDataInjector, external: TestSavingProductsExternalDependencies) {
        self.injector = injector
        self.external = external
    }
    
    func resolve() -> SavingsHomeCoordinator {
        fatalError()
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> GetSavingTransactionsUseCase {
        DefaultGetSavingTransactionsUseCase(repository: external.resolve())
    }
}
