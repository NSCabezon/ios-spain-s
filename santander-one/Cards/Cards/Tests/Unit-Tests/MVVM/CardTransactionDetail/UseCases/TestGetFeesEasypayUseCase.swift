//
//  GetFeesEasypayUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import CoreTestData
import XCTest
@testable import Cards

class TestGetFeesEasypayUseCase: XCTestCase {
    private let card = MockCard()
    private lazy var dependencies: TestCardTransactionDetailDependencies = {
        let external = TestCardTransactionExternalDependencies(injector: self.mockDataInjector)
        return TestCardTransactionDetailDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    private lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.injectMockCardData()
        return injector
    }()
}

extension TestGetFeesEasypayUseCase {
    func test_when_fetchFeesEasypay_expect_succes() throws {
        let sut: GetFeesEasypayUseCase = DefaultGetFeesEasypayUseCase(dependencies: dependencies.external)
        
        let response = try sut
            .fetchFeesEasypay(card: card)
            .sinkAwait()
        XCTAssertNotNil(response)
        XCTAssertTrue(response.JTIPRAN == "M")
        XCTAssertTrue(response.minPeriodCount == 2)
        XCTAssertTrue(response.maxPeriodCount == 36)
        XCTAssertTrue(response.periodInc == 1)
    }
}
