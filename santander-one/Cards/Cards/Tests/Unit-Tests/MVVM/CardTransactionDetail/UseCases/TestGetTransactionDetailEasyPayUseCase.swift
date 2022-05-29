//
//  TestGetTransactionDetailEasyPayUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 18/4/22.
//

import CoreTestData
import XCTest
@testable import Cards

class TestGetTransactionDetailEasyPayUseCase: XCTestCase {
    private let card = MockCard()
    private let transaction = MockCardTransaction()
    private let cardDetail = MockCardDetail()
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

extension TestGetTransactionDetailEasyPayUseCase {
    func test_when_fetchTransactionDetailEasyPay_expect_succes() throws {
        let sut: GetTransactionDetailEasyPayUseCase = DefaultGetTransactionDetailEasyPayUseCase(dependencies: dependencies.external)
        
        let response = try sut
            .fetchTransactionDetailEasyPay(card: card,
                                           transaction: transaction,
                                           cardDetail: cardDetail,
                                           easyPayContract: nil)
            .sinkAwait()
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isFractioned)
        XCTAssertTrue(response.easyPay?.paymentMethod == "PA")
        XCTAssertTrue(response.easyPay?.feeVariationType == "E")
        XCTAssertTrue(response.easyPay?.supportCode == "999")
        XCTAssertTrue(response.easyPay?.transactionOperationModeType == "02")
    }
}
