import CoreTestData
import XCTest
@testable import Cards

class GetCardAvailableFiltersUseCaseTest: XCTestCase {
    lazy var dependencies: TestCardTransactionFiltersDependencies = {
        let external = TestCardTransactionFiltersExternalDependencies(injector: self.mockDataInjector)
        return TestCardTransactionFiltersDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_default_availableFilters_shouldReturnFalse_allFilters() throws {
        let sut = DefaultCardTransactionAvailableFiltersUseCase()
        
        let filters = try sut.fetchAvailableFiltersPublisher().sinkAwait()
        XCTAssertFalse(filters.byAmount)
        XCTAssertFalse(filters.byExpenses)
        XCTAssertFalse(filters.byTypeOfMovement)
        XCTAssertFalse(filters.byConcept)
    }
}

