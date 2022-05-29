//
//  SavingProductViewModelTest.swift
//  SavingProducts-Unit-Tests
//
//  Created by Adrian Escriche Martin on 4/4/22.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import SavingProducts


class SavingProductViewModelTest: XCTestCase {
    lazy var dependencies: TestSavingProductsHomeDependencies = {
        let externalDependencies = TestSavingProductsExternalDependencies(injector: self.mockDataInjector)
        return TestSavingProductsHomeDependencies(injector: self.mockDataInjector, external: externalDependencies)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobalWithSavingProducts")
        injector.register(
            for: \.savingProductsData.getSavingProductTransactions,
            filename: "SavingProductTransactionsListDTOMock")
        return injector
    }()
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_includeGlobalPositionSavings() throws {
        //G
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        let publisher = testViewModel.state
            .case(SavingsState.savingsLoaded)
        //W
        testViewModel.viewDidLoad()
        //T
        let savingProducts = try publisher.sinkAwait()
        XCTAssertFalse(savingProducts.isEmpty)
    }
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_getMaxNumberOfComplementaryFields() throws {
        //G
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        let publisher = testViewModel.state
            .case(SavingsState.savingsLoaded)
        let complementaryData: GetSavingProductComplementaryDataUseCase = dependencies.external.resolve()
        //W
        testViewModel.viewDidLoad()
        //T
        let savingProducts = try publisher.sinkAwait()
        let complementaryDataValues = try complementaryData.fechComplementaryDataPublisher().sinkAwait()
        var maxNumberOfFields = 0
        savingProducts.forEach { savingProduct in
            complementaryDataValues.forEach { data in
                if data.key == savingProduct.accountSubtype {
                    savingProduct.complementaryData = data.value
                }
            }
        }
        savingProducts.forEach { value in
            let numberOfFields = value.complementaryData.count
            if numberOfFields > maxNumberOfFields {
                maxNumberOfFields = numberOfFields
            }
        }
        XCTAssertEqual(maxNumberOfFields, 3)
    }
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_getLongestSavingsID() throws {
        //G
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        let publisher = testViewModel.state
            .case(SavingsState.savingsLoaded)
        //W
        testViewModel.viewDidLoad()
        //T
        let savingProducts = try publisher.sinkAwait()
        
        var idToReturn: String = ""
        savingProducts.forEach { value in
            let identification = value.identification
            if  identification.count > idToReturn.count {
                idToReturn = identification
            }
        }
        XCTAssertEqual(idToReturn, "Saving Test Demo 1")
    }
    
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_includeSavingProductsOptions() throws {
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        testViewModel.viewDidLoad()
    
        let publisher = try testViewModel.state
            .case(SavingsState.options)
            .sinkAwait()
        XCTAssertFalse(publisher.isEmpty)
    }
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_includeSavingProductTransactions() throws {
        //G
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        testViewModel.viewDidLoad()
        //W
        let publisher = try testViewModel.state
            .case(SavingsState.transactionsLoaded)
            .sinkAwait()
        XCTAssertFalse(publisher.isEmpty)
    }
    
    func test_Given_savingProducts_When_enteringSavingProductsHome_Then_checkIfHasPendingField() throws {
        //G
        let testViewModel = SavingsHomeViewModel(dependencies: dependencies)
        let publisher = testViewModel.state
            .case(SavingsState.pendingFieldLoaded)
        //W
        testViewModel.viewDidLoad()
        //T
        let savingProducts = try publisher.sinkAwait()
        XCTAssertFalse(savingProducts.isEmpty)
    }
}
