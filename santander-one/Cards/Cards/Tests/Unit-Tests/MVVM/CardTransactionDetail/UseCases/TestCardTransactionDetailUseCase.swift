//
//  TestCardTransactionDetailUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 18/4/22.
//

import CoreTestData
import XCTest
@testable import Cards

class TestCardTransactionDetailUseCase: XCTestCase {
    private let card = MockCard()
    private let transaction = MockCardTransaction()
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

extension TestCardTransactionDetailUseCase {
    func test_when_fetchCardDetailDataUseCase_expect_succes() throws {
        let sut: CardTransactionDetailUseCase  = DefaultCardTransactionDetailUseCase(dependencies: dependencies.external)
        
        let response = try sut
            .fetchCardDetailDataUseCase(card: card,
                                        transaction: transaction,
                                        showAmountBackground: true)
            .sinkAwait()
        XCTAssertNotNil(response)
        XCTAssertNotNil(response.configuration)
        XCTAssertTrue(response.configuration?.isSplitExpensesEnabled == true)
        XCTAssertFalse(response.configuration?.isEnabledMap == true)
        XCTAssertFalse(response.isFractioned)
        XCTAssertTrue(response.showAmountBackground)
        XCTAssertNotNil(response.transactionDetail)
        XCTAssertFalse(response.transactionDetail?.isSoldOut == true)
        XCTAssertNotNil(response.cardDetail)
        XCTAssertTrue(response.cardDetail?.linkedAccount == "0049 1262 28 2195076311")
    }
}
