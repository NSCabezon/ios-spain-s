//
//  TestGetSingleCardMovementLocationUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import CoreTestData
import XCTest
@testable import Cards

class TestGetSingleCardMovementLocationUseCase: XCTestCase {
    private let card = MockCard()
    private let transaction = MockCardTransaction()
    private let detail = MockCardTransactionDetail()
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

extension TestGetSingleCardMovementLocationUseCase {
    func test_when_fetchSingleCardMovementLocation_expect_success() throws {
        let sut: GetSingleCardMovementLocationUseCase = DefaultGetSingleCardMovementLocationUseCase(dependencies: dependencies.external)
        let response = try sut.fetchSingleCardMovementLocation(card: card,
                                                               transaction: transaction,
                                                               transactionDetail: detail)
            .sinkAwait()
        XCTAssertNotNil(response)
        XCTAssertTrue(response.status == .locatedMovement)
        XCTAssertTrue(response.location.latitude == 41.6484937)
        XCTAssertTrue(response.location.longitude == -4.7293842)
    }
}
