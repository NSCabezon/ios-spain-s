//
//  AnalysisAreaDeleteOtherBankConnectionUseCaseTests.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 24/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import CoreDomain
@testable import Menu

final class AnalysisAreaDeleteOtherBankConnectionUseCaseTests: XCTestCase {
    private lazy var dependencies: TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver(injector: self.mockDataInjector, externalDependencies: external)
    }()
    private lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.financialHealthData.summary, filename: "getFinancialHealthSummary")
        injector.register(
            for: \.financialHealthData.companies, filename: "getFinancialHealthCompaniesWithProducts")
        injector.register(
            for: \.financialHealthData.productsStatus, filename: "getFinancialHealthProductsStatus")
        injector.register(
            for: \.financialHealthData.updateProductStatus, filename: "getFinancialHealthProductsStatus")
        injector.register(
            for: \.financialHealthData.preferences, filename: "getFinancialHealthPreferences")
        return injector
    }()
    
    private var mockDeleteBankInput = "0049"
    private var mockDeleteBankInputFail = ""
    
    func test_Given_expectedGetDeleteBankMock_When_getDeleteOtherBankConnectionUseCaseIsCalled_Then_receivedVoidValue() throws {
        let sut: DeleteOtherBankConnectionUseCase = dependencies.resolve()
        _ = sut.fetchFinancialDeleteBankPublisher(bankCode: mockDeleteBankInput).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }, receiveValue: { _ in
            XCTAssert(true)
        })
    }
    
    func test_Given_noExpectedGetDeleteBankMock_When_getDeleteOtherBankConnectionUseCaseIsCalled_Then_getFailure() throws {
        let sut: DeleteOtherBankConnectionUseCase = dependencies.resolve()
        _ = sut.fetchFinancialDeleteBankPublisher(bankCode: mockDeleteBankInputFail).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTFail()
            case .failure:
                XCTAssertTrue(true)
            }
        }, receiveValue: { _ in
            XCTFail()
        })
    }
}
