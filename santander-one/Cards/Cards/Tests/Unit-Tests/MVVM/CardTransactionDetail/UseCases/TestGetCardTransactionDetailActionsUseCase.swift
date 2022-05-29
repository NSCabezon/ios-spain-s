//
//  GetCardTransactionDetailActionsUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import CoreTestData
import XCTest
@testable import Cards

class TestGetCardTransactionDetailActionsUseCase: XCTestCase {
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

extension TestGetCardTransactionDetailActionsUseCase {
    func test_when_fetchCardTransactionDetailActions_expect_succes() throws {
        let sut: GetCardTransactionDetailActionsUseCase = DefaultGetCardTransactionDetailActionsUseCase(dependencies: dependencies.external)
        let item = MockCardTransactionViewItem(card: card,
                                               transaction: transaction,
                                               showAmountBackground: true)
        let response = try sut
            .fetchCardTransactionDetailActions(item: item)
            .sinkAwait()
        XCTAssertNotNil(response)
        XCTAssertTrue(response[0].type == .offCard)
        XCTAssertTrue(response[1].type == .share(ShareableCard(card: card)))
        XCTAssertTrue(response[2].type == .pdfDetail)
    }
}
