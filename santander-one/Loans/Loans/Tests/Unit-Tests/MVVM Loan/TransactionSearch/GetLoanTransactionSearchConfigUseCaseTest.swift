////
////  LoanTransactionSearchViewModelTest.swift
////  ExampleAppTests
////
////  LoanDetailCoordinatorSpy.swiftLoanDetailCoordinatorSpy.swift
////
//
import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Loans

class GetLoanTransactionSearchConfigUseCaseTest: XCTestCase {
    lazy var externalDependencies = TestLoanTransactionSearchExternalDependencies(injector: self.mockDataInjector)
    lazy var dependencies: TestLoanTransactionSearchDependencies = {
        return TestLoanTransactionSearchDependencies(injector: self.mockDataInjector, externalDependencies: externalDependencies)
    }()

    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_Given_PreviusFilter_When_viewDidLoad_Then_ViewModelFilterIsSetted() throws {
        let sut = DefaultGetLoanTransactionSearchConfigUseCase()
        
        let config = try sut.fetchConfiguration().sinkAwait()
            
        XCTAssertTrue(config.isEnabledAmountRangeFilter)
        XCTAssertTrue(config.isEnabledDateFilter)
    }
}
