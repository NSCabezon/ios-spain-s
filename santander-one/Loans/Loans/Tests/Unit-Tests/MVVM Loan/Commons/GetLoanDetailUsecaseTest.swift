//
//  GetLoanDetailUsecaseTest.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 2/3/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreTestData
import XCTest
@testable import Loans

class GetLoandDetailUsecaseTest: XCTestCase {
    lazy var dependencies: TestLoanCommonExternalDependencies = {
        return TestLoanCommonExternalDependencies(injector: mockDataInjector)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobalWithLoans")
        injector.register(
            for: \.loansData.getLoanDetail,
            filename: "LoanDetailDTOMock")
        injector.register(
            for: \.loansData.getLoanTransactions,
            filename: "LoanTransactionsListDTOMock")
        injector.register(
            for: \.loansData.getLoanTransactionDetail,
            filename: "LoanTransactionDetailDTOMock")
        return injector
    }()
    
    func test_When_FechDetailPublisher_Then_InfoIsSetted() throws {
        let sut = DefaultGetLoanDetailUsecase(dependencies: dependencies)
        
        let detail = try sut.fechDetailPublisher(loan: MockLoan()).sinkAwait()
        XCTAssert(detail.holder == "00123456")
        XCTAssert(detail.linkedAccountDesc == "Cuenta principal")
    }
}
