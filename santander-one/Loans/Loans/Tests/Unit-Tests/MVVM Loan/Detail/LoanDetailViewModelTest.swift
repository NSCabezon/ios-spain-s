//
//  LoanDetailViewModelTest.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 24/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreTestData
import XCTest
import OpenCombine
import CoreDomain
import CoreFoundationLib
@testable import Loans

class LoanDetailViewModelTest: XCTestCase {
    
    lazy var dependenciesExternal = TestLoanDetailExternalDependencies(injector: mockDataInjector)
    
    lazy var dependencies: TestLoanDetailDependencies = {
        return TestLoanDetailDependencies(injector: mockDataInjector, externalDependencies: dependenciesExternal)
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
        return injector
    }()
    
    func test_Given_NotBindingLoanReceived_When_ViewDidLoad_Then_NoInfoLoaded() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
             
        sut.viewDidLoad()

        XCTAssertFalse(self.dependencies.getLoanDetailConfigUseCaseSpy.getLoanDetailConfigUseCaseCalled)
        XCTAssertFalse(self.dependenciesExternal.getLoanDetailUseCaseSpy.getLoanDetailUseCaseCalled)
    }
    
    func test_Given_BindingLoanAndDetail_When_ViewDidLoad_Then_OnlyConfigLoaded() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
             
        let trigger = {
            let mockLoan = MockLoan(productIdentifier: "loan")
            let mockLoanDetail = MockLoanDetail()
            sut.dataBinding.set(mockLoan)
            sut.dataBinding.set(mockLoanDetail)
            sut.viewDidLoad()
        }
        
        _ = try sut.state
            .case(LoanDetailState.detailLoaded)
            .sinkAwait(beforeWait: trigger)
        
        _ = try sut.state
            .case(LoanDetailState.configurationLoaded)
            .sinkAwait(beforeWait: trigger)

        XCTAssertTrue(self.dependencies.getLoanDetailConfigUseCaseSpy.getLoanDetailConfigUseCaseCalled)
        XCTAssertFalse(self.dependenciesExternal.getLoanDetailUseCaseSpy.getLoanDetailUseCaseCalled)
    }
    
    func test_Given_BindingLoanReceived_When_ViewDidLoad_Then_CallAllInfoLoaded() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
             
        let trigger = {
            let mockLoan = MockLoan(productIdentifier: "loan")
            sut.dataBinding.set(mockLoan)
            sut.viewDidLoad()
        }
        
        _ = try sut.state
            .case(LoanDetailState.detailLoaded)
            .sinkAwait(beforeWait: trigger)
        
        _ = try sut.state
            .case(LoanDetailState.configurationLoaded)
            .sinkAwait(beforeWait: trigger)

        XCTAssertTrue(self.dependencies.getLoanDetailConfigUseCaseSpy.getLoanDetailConfigUseCaseCalled)
        XCTAssertTrue(self.dependenciesExternal.getLoanDetailUseCaseSpy.getLoanDetailUseCaseCalled)
    }
    
    func test_Given_SettedLoan_When_DidTapOnShare_Then_CallShareCoordinator() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
        let mockLoanDetail = MockLoanDetail(linkedAccountDesc: "descripcion")
        sut.dataBinding.set(mockLoanDetail)
        sut.viewDidLoad()
             
        sut.didTapOnShare()
        
        XCTAssertTrue(self.dependencies.coordinatorSpy.shareCalled)
    }
    
    func test_Given_ViewModel_When_DidSelectMenu_Then_CallDidSelectMenuCoordinator() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
             
        sut.didSelectMenu()
        
        XCTAssertTrue(self.dependencies.coordinatorSpy.didSelectMenuCalled)
    }
    
    func test_Given_ViewModel_When_DidSelectBack_Then_CallCoordinatorDismiss() throws {
        let sut = LoanDetailViewModel(dependencies: dependencies)
             
        sut.didSelectBack()
        
        XCTAssertTrue(self.dependencies.coordinatorSpy.dismissCalled)
    }
}
