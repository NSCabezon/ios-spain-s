//
//  TestSpainCardTransactionsAvailableFiltersUseCase.swift
//  SantanderTests
//
//  Created by José Carlos Estela Anguita on 4/5/22.
//

import Foundation
import XCTest
import CoreDomain
import CoreTestData
@testable import Santander
import UnitTestCommons

final class TestSpainCardTransactionAvailableFiltersUseCase: XCTestCase {
    
    var useCase: SpainCardTransactionAvailableFiltersUseCase!
    
    override func setUp() {
        super.setUp()
        useCase = SpainCardTransactionAvailableFiltersUseCase()
    }
    
    override func tearDown() {
        super.tearDown()
        useCase = nil
    }
    
    func test_availableFilters_shouldReturnTrueForConcept_andTypeOfMovement() throws {
        let result = try useCase.fetchAvailableFiltersPublisher().sinkAwait()
        XCTAssert(result.byAmount == false)
        XCTAssert(result.byExpenses == false)
        XCTAssert(result.byConcept == true)
        XCTAssert(result.byTypeOfMovement == true)
    }
}
