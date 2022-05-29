//
//  LoanTransactionSearchViewModelTest.swift
//  ExampleAppTests
//
//  LoanDetailCoordinatorSpy.swiftLoanDetailCoordinatorSpy.swift
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Loans

class LoanTransactionSearchViewModelTest: XCTestCase {
    lazy var externalDependencies = TestLoanTransactionSearchExternalDependencies(injector: self.mockDataInjector)
    lazy var dependencies: TestLoanTransactionSearchDependencies = {
        return TestLoanTransactionSearchDependencies(injector: self.mockDataInjector, externalDependencies: externalDependencies)
    }()

    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobalWithLoans")
        return injector
    }()
    
    func test_Given_PreviusFilter_When_viewDidLoad_Then_ViewModelFilterIsSetted() throws {
        
        let sut = LoanTransactionSearchViewModel(dependencies: dependencies)
             
        let trigger = {
            let mockFilter = ActiveFilters.byAmount(from: "1", limit: "3")
            let mockFiltersEntity = TransactionFiltersEntity()
            mockFiltersEntity.filters = [mockFilter]
            sut.dataBinding.set(mockFiltersEntity)
            sut.viewDidLoad()
        }
        
        let filtersEntity = try sut.state
            .case(LoanTransactionSearchState.initialFilters)
            .sinkAwait(beforeWait: trigger)

        XCTAssertTrue(filtersEntity.filters.count == 1)
    }

    func test_Given_ViewModel_When_viewDidLoad_Then_SubscribeToConfigEventIsCalled() throws {
        let sut = LoanTransactionSearchViewModel(dependencies: dependencies)
             
        let trigger = {
            sut.viewDidLoad()
        }
        
        let _ = try sut.state
            .case(LoanTransactionSearchState.configurationLoaded)
            .sinkAwait(beforeWait: trigger)

        XCTAssertTrue(self.externalDependencies.getLoanTransactionSearchConfigUseCaseSpy.getLoanTransactionSearchConfigUseCaseCalled)
    }
    
    func test_Given_ViewModel_When_Close_Then_CallDissmissWithoutApplyFiltersCoordinator() throws {
        let sut = LoanTransactionSearchViewModel(dependencies: dependencies)
             
        sut.close()
        
        XCTAssertFalse(self.dependencies.coordinatorSpy.didApplyFilterCalled)
        XCTAssertTrue(self.dependencies.coordinatorSpy.dismissCalled)
    }
    
    func test_Given_ViewModel_When_ApplyCalled_Then_CallDissmisCoordinator() throws {
        let sut = LoanTransactionSearchViewModel(dependencies: dependencies)

        sut.returnWithFilters(filters: TransactionFiltersEntity())

        XCTAssertTrue(self.dependencies.coordinatorSpy.dismissCalled)
    }
}
