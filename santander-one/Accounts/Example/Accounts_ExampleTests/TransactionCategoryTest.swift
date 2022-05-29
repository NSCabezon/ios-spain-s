//
//  Accounts_ExampleTests.swift
//  Accounts_ExampleTests
//
//  Created by Boris Chirino Fernandez on 28/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import UnitTestCommons
import SANLegacyLibrary
import CoreTestData
@testable import CoreFoundationLib
@testable import Account

class TransactionCategoryTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()

    override func setUpWithError() throws {
        self.setupDependencies()
    }
    
    func test_GetTransactionCategoryUseCase_response() throws {
        //G
        mockDataInjector.register(
            for: \.accountData.getAccountTransactionCategoryMock,
            filename: "transactionCategoryMovements"
        )
        let input = TransactionCategoryUseCaseInput(
            dgoNumber: "00490072BH2443",
            transactionDescription: "Compra mercadona",
            amount: 49.50,
            date: Date()
        )
        let useCase = GetTransactionCategoryUseCase(dependenciesResolver: self.dependenciesResolver)
        //W
        let response = try useCase.executeUseCase(requestValues: input)
        guard response.isOkResult else {
            XCTFail("GetTransactionCategoryUseCase fail")
            return
        }
        let categoryResponse = try response.getOkResult()
        //T
        XCTAssertEqual(categoryResponse.category, "Comercio y Tiendas")
    }
    
    func test_mocked_GetTransactionCategoryUseCase_requestValues() throws {
        //G
        let today = Date()
        let input = TransactionCategoryUseCaseInput(
            dgoNumber: "00490072BH2443",
            transactionDescription: "Compra mercadona",
            amount: 49.50,
            date: today
        )
        let useCase = GetTransactionCategoryUseCaseMock(dependenciesResolver: self.dependenciesResolver)
        //W
        _ = try useCase.executeUseCase(requestValues: input)
        //T
        waitForAssume(spying: useCase.dgoNumber, expectedValue: "00490072BH2443")
        waitForAssume(spying: useCase.amount, expectedValue: 49.50)
        waitForAssume(spying: useCase.date, expectedValue: today)
        waitForAssume(spying: useCase.transactionDescription, expectedValue: "Compra mercadona")
    }
}

// MARK: - Mocks
class GetTransactionCategoryUseCaseMock: GetTransactionCategoryUseCase {
    var dgoNumber: SpyableObject<String> = SpyableObject(value: "")
    var transactionDescription: SpyableObject<String> = SpyableObject(value: "")
    var amount: SpyableObject<Decimal> = SpyableObject(value: 0.0)
    var date: SpyableObject<Date> = SpyableObject(value: Date())
    
    override func executeUseCase(requestValues: TransactionCategoryUseCaseInput) throws -> UseCaseResponse<TransactionCategoryUseCaseOkOutPut, StringErrorOutput> {
        self.dgoNumber = SpyableObject(value: requestValues.dgoNumber)
        self.transactionDescription = SpyableObject(value: requestValues.transactionDescription)
        self.amount = SpyableObject(value: requestValues.amount)
        self.date = SpyableObject(value: requestValues.date)
        return try super.executeUseCase(requestValues: requestValues)
    }
}

// MARK: - extensions
private extension TransactionCategoryTest {
    func setupDependencies() {
        self.dependenciesResolver.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
    }
}
