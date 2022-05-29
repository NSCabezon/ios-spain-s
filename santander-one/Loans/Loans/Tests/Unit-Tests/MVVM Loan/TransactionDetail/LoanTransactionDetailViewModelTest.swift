//
//  LoanTransactionDetailViewModelTest.swift
//  Loans
//
//  Created by alvola on 9/3/22.
//

import XCTest
import CoreTestData
import OpenCombine
import CoreFoundationLib
@testable import Loans

final class LoanTransactionDetailViewModelTest: XCTestCase {
    lazy var external: TestLoanTransactionDetailExternalDependencies = {
        return TestLoanTransactionDetailExternalDependencies(injector: mockDataInjector)
    }()
    lazy var dependencies: TestLoanTransactionDetailDependencies = {
        return TestLoanTransactionDetailDependencies(injector: mockDataInjector,
                                                     externalDependencies: external)
    }()
    
    lazy var dataBinding = DataBindingObject()
    
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

    func test_given_receiptIdAndNoPDFInfo_when_showPDFPressedAndExistPDFData_then_loadingIsShown() throws {
        var transaction = MockLoanTransaction()
        transaction.receiptId = "12345678"
        external.dataToTestPDF = "".data(using: .utf8)
        let detail = LoanTransactionDetail(transaction: transaction,
                                           loan: MockLoan(),
                                           accountNumberFormatter: AccountNumberFormatterMock())
        let sut = LoanTransactionDetailViewModel(dependencies: dependencies)
        let trigger = {
            sut.didSelectAction(.pdfExtract(nil),
                                transactionDetail: detail)
        }
        let isLoading = try sut.state
            .case(LoanTransactionDetailState.isLoading)
            .sinkAwait(beforeWait: trigger)
        
        XCTAssertTrue(isLoading)
    }
    
    func test_given_receiptIdAndNoPDFInfo_when_showPDFPressedAndNoPDFData_then_errorIsShown() throws {
        var transaction = MockLoanTransaction()
        transaction.receiptId = "12345678"
        let detail = LoanTransactionDetail(transaction: transaction,
                                           loan: MockLoan(),
                                           accountNumberFormatter: AccountNumberFormatterMock())
        let sut = LoanTransactionDetailViewModel(dependencies: dependencies)
        let trigger = {
            sut.didSelectAction(.pdfExtract(nil),
                                transactionDetail: detail)
        }
        let isErrorShown = try sut.state
            .case(LoanTransactionDetailState.errorReceived)
            .flatMap({ () in
                return Just(true).eraseToAnyPublisher()
            })
            .sinkAwait(beforeWait: trigger)
        
        XCTAssertTrue(isErrorShown)
    }
    
    func test_given_validLoanAndTransactionList_when_moduleStarts_then_transactionListIsPublished() throws {
        let sut = LoanTransactionDetailViewModel(dependencies: dependencies)
        sut.dataBinding.set(MockLoan())
        sut.dataBinding.set(mockDataInjector.mockDataProvider.loansData.getLoanTransactions.transactionDTOs)
        
        sut.viewDidLoad()
        let transactionLoaded = try sut.state
            .case(LoanTransactionDetailState.transactionsLoaded)
            .sinkAwait()
        
        XCTAssertTrue(transactionLoaded.list.isNotEmpty)
    }
    
    func test_given_twoValidActions_when_viewDidLoad_then_publish2Actions() throws {
        external.actions = [MockLoanTransactionDetailAction(type: .share),
                            MockLoanTransactionDetailAction(type: .showDetail)]
        dependencies.dataBinding.set(MockLoan())
        dependencies.dataBinding.set(MockLoanTransaction())
        let sut = LoanTransactionDetailViewModel(dependencies: dependencies)
        
        sut.viewDidLoad()
        let actionsLoaded = try sut.state
            .case(LoanTransactionDetailState.actionsLoaded)
            .sinkAwait()
        
        XCTAssertTrue(actionsLoaded.actions.count == 2)
    }
    
    func test_given_configurationWithTwoFields_when_viewDidLoad_then_publishTheCorrectConfiguration() throws {
        external.fields = LoanTransactionDetailConfigurationMock(LoanTransactionDetailConfiguration.full)
        let sut = LoanTransactionDetailViewModel(dependencies: dependencies)
        sut.dataBinding.set(MockLoan())
        sut.dataBinding.set(mockDataInjector.mockDataProvider.loansData.getLoanTransactions.transactionDTOs)
        
        sut.viewDidLoad()
        let configurationLoaded = try sut.state
            .case(LoanTransactionDetailState.transactionsLoaded)
            .sinkAwait()
        
        let fields = configurationLoaded.detailConfig.fields
        let validConfig = fields.contains { $0.0.value == .operationDate }
        && fields.contains { $0.1?.value == .valueDate }
        XCTAssertTrue(validConfig)
    }
}
