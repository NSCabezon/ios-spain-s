//
//  LoanHomeViewModelTest.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 11/5/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Loans

class LoanHomeViewModelTest: XCTestCase {
    lazy var dependencies: TestLoanHomeDependencies = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestLoanHomeDependencies(injector: self.mockDataInjector, externalDependencies: external)
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

    func test_getLoans_includeGlobalPositionLoans() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        let publisher = sut.state
            .case(LoanState.loansLoaded)
        sut.viewDidLoad()
        let loans = try publisher.sinkAwait()
        XCTAssertFalse(loans.isEmpty)
    }

    func test_getTransactions_withSelectedLoan_includeLoanTransactions() throws {
        // given
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(LoanState.transactionsLoaded)
        
        // when
        sut.didSelectLoan(Loan(loan: MockLoan(), dependencies: dependencies))
        
        // then
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result.isEmpty)
    }
    
    func test_failGetTransactions_withSelectedLoan_includeEmptyTransactions() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(LoanState.transactionError)
        let mockFailLoan = MockLoan(productIdentifier: "fail")
        sut.didSelectLoan(Loan(loan: mockFailLoan, dependencies: self.dependencies))
        let result: LocalizedError = try publisher.sinkAwait()
        XCTAssertEqual(result.localizedDescription, "generic_label_emptyNotAvailableMoves")
    }

    func test_getLoanDetail_withSelectedLoan_includeLoanDetail() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(LoanState.detailLoaded)
        sut.didSelectLoan(Loan(loan: MockLoan(), dependencies: self.dependencies))
        let loanDetail = try publisher.sinkAwait()
        XCTAssertNotNil(loanDetail)
    }
    
    func test_failGetLoanDetail_withSelectedLoan_includeNilDetail() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let mockFailLoan = MockLoan(productIdentifier: "fail")
        sut.didSelectLoan(Loan(loan: mockFailLoan, dependencies: self.dependencies))
        let publisher = sut.state
            .case(LoanState.detailLoaded)
        let loanDetail = try publisher.sinkAwait()
        XCTAssertNil(loanDetail)
    }

    func test_getLoanOptions_withAppconfig_includePaymentLinkAccountAndDetailOptions() throws {
        let appconfig = AppConfigDTOMock(defaultConfig: [
            "enableLoanRepayment": "true",
            "enableChangeLoanLinkedAccount": "true"
        ])
        mockDataInjector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            element: appconfig
        )

        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()

        let publisher = sut.state
            .case(LoanState.options)
        let result = try publisher.sinkAwait()

        let expeted = expectedOptions.map {
                AnyEquatable($0)
        }
        let options = result.map {
            AnyEquatable($0)
        }
        XCTAssertEqual(expeted, options)
    }

    func test_hidePaginationLoading_whenFinishLoadingMoreTransactions() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let trigger = {
            let mockPaginationLoan = MockLoan(productIdentifier: "pagining")
            sut.didSelectLoan(Loan(loan: mockPaginationLoan, dependencies: self.dependencies))
        }
        let _ = try sut.state
            .case(LoanState.transactionsLoaded)
            .sinkAwait(beforeWait: trigger)
        
        let isPaginationShown = try sut.state
            .case(LoanState.isPaginationLoading)
            .sinkAwait(beforeWait: sut.loadMoreTransactions)

        XCTAssertFalse(isPaginationShown)
    }

    func test_showHideTransactionLoading_withSelectedLoan() throws {
        let sut = LoanHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let trigger = {
            sut.didSelectLoan(Loan(loan: MockLoan(), dependencies: self.dependencies))
        }
        let isTransactionLoading = try sut.state
            .case(LoanState.isTransactionLoading)
            .sinkAwait(beforeWait: trigger)
        XCTAssertTrue(isTransactionLoading)
    }
    
    func test_anyEquatable() throws {
        let expectedRepresentable: LoanOptionRepresentable =
            LoanOption(title: "loansOption_button_anticipatedAmortization",
                           imageName: "icnEarlyRepayment",
                           accessibilityIdentifier: "LoansHomeBtnPayment",
                           type: .repayment)
        
        let expected = AnyEquatable(expectedRepresentable)
        let loan = AnyEquatable(expectedOptions[0])
        
        XCTAssert(expected == loan)
        XCTAssertEqual([expected], [loan])
    }
}

// MARK: Helpers Objects
fileprivate extension LoanHomeViewModelTest {

    struct LoanOption: LoanOptionRepresentable {
        let title: String
        let imageName: String
        let accessibilityIdentifier: String
        let type: LoanOptionType
        var titleIdentifier: String?
        var imageIdentifier: String?
        
        init(option: LoanOptionRepresentable) {
            self.title = option.title
            self.imageName = option.imageName
            self.accessibilityIdentifier = option.accessibilityIdentifier
            self.type = option.type
        }
        
        init(title: String, imageName: String,
             accessibilityIdentifier: String,
             type: LoanOptionType) {
            self.title = title
            self.imageName = imageName
            self.accessibilityIdentifier = accessibilityIdentifier
            self.type = type
        }
    }
    
    var expectedOptions: [LoanOptionRepresentable] {
        return [LoanOption(title: "loansOption_button_anticipatedAmortization",
                           imageName: "icnEarlyRepayment",
                           accessibilityIdentifier: "LoansHomeBtnPayment",
                           type: .repayment),
                
                LoanOption(title: "loansOption_button_changeAccount",
                           imageName: "icnChangeAssociatedAccount",
                           accessibilityIdentifier: "LoansHomeBtnChangeAccount",
                           type: .changeLoanLinkedAccount),
                
                LoanOption(title: "loansOption_button_detailLoan",
                           imageName: "icnDetail",
                           accessibilityIdentifier: "LoansHomeBtnDetail",
                           type: .detail)]
    }
}
