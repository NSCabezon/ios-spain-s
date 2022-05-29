//
//  TestGetCardTransactionDetailViewConfigurationUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import CoreFoundationLib
import CoreTestData
import XCTest
@testable import Cards

class TestGetCardTransactionDetailViewConfigurationUseCase: XCTestCase {
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

extension TestGetCardTransactionDetailViewConfigurationUseCase {
    func test_when_ffetchCardTransactionDetailViewConfiguration_expect_succes() throws {
        let sut: GetCardTransactionDetailViewConfigurationUseCase = DefaultGetCardTransactionDetailViewConfigurationUseCase()
        let leftTitle: String = localized("transaction_label_operationDate")
        let rightTitle: String = localized("cardDetail_text_liquidated")
        let response = try sut
            .fetchCardTransactionDetailViewConfiguration(transaction: transaction,
                                                         detail: detail)
            .sinkAwait()
        XCTAssertNotNil(response.first)
        XCTAssertTrue(response.first?.leftRepresentable?.title == leftTitle)
        XCTAssertTrue(response.first?.rightRepresentable?.title == rightTitle)
    }
}
