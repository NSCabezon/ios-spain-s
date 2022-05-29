import Foundation
import XCTest
import UnitTestCommons
import CoreFoundationLib
import CoreDomain
import CoreTestData
@testable import Cards

final class TestCardTransactionFiltersViewModel: XCTestCase {
    lazy var dependencies: TestCardTransactionFiltersDependencies = {
        let external = TestCardTransactionFiltersExternalDependencies(injector: self.mockDataInjector)
        return TestCardTransactionFiltersDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    lazy var dependenciesExternal = TestCardTransactionFiltersExternalDependencies(injector: mockDataInjector)
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal")
        return injector
    }()
    
}

extension TestCardTransactionFiltersViewModel {
    
    func test_BindingCardTransactionAvailableFilters_When_ViewDidLoad() throws {
        let sut = CardTransactionFiltersViewModel(dependencies: dependencies)
        
        sut.viewDidLoad()
        let publisher = sut.state.case(CardTransactionFiltersState.availableFiltersLoaded)
        let filters = try publisher.sinkAwait()
       
        XCTAssertFalse(filters.byTypeOfMovement)
        XCTAssertFalse(filters.byAmount)
        XCTAssertFalse(filters.byConcept)
        XCTAssertFalse(filters.byExpenses)
    }
    
    
    func test_BindingCardTransactionFilters_When_ViewDidLoad() throws {
        let sut = CardTransactionFiltersViewModel(dependencies: dependencies)
        let dateFilter =  CardTransactionFilterDate(startDate: Date().addDay(days: -7), endDate: Date(), indexRange: 0)
        let filters: [CardTransactionFilterType] = [CardTransactionFilterType.byDate(dateFilter), CardTransactionFilterType.byExpenses(.income), CardTransactionFilterType.byTypeOfMovement(.payment), CardTransactionFilterType.byAmount(.from(100)), CardTransactionFilterType.byConcept("test") ]
        dependencies.dataBinding.set(filters)
        sut.viewDidLoad()
        let publisher = sut.state.case(CardTransactionFiltersState.filtersLoaded)
        let filtersLoaded = try publisher.sinkAwait()
        XCTAssert(!filtersLoaded.isEmpty)
      
    }
    
    func test_BindingCardTransactionFilters_ShouldReturn_ConceptFilter() throws {
        let sut = CardTransactionFiltersViewModel(dependencies: dependencies)
        let filters: [CardTransactionFilterType] = [CardTransactionFilterType.byConcept("test"), CardTransactionFilterType.byTypeOfMovement(.payment)]
        dependencies.dataBinding.set(filters)
        sut.viewDidLoad()
        let publisher = sut.state.case(CardTransactionFiltersState.filtersLoaded)
        let filtersLoaded = try publisher.sinkAwait()
        XCTAssert(filtersLoaded.contains(where: { $0.isByConcept }))
      
    }
    
    
    func test_saveCardTransactionFilters() throws {
        let dateFilter =  CardTransactionFilterDate(startDate: Date().addDay(days: -7), endDate: Date(), indexRange: 0)
        let filters: [CardTransactionFilterType] = [CardTransactionFilterType.byDate(dateFilter), CardTransactionFilterType.byExpenses(.income), CardTransactionFilterType.byTypeOfMovement(.payment), CardTransactionFilterType.byAmount(.from(100)), CardTransactionFilterType.byConcept("test") ]
        struct FilterRepresentable: CardTransactionFiltersRepresentable {
            var cardFilters: [CardTransactionFilterType]
        }
        
        let filtersToTest = FilterRepresentable(cardFilters: filters)
        let filtersEntity = filtersToTest.toEntity()
       
        XCTAssertEqual(filtersEntity.fromAmountDecimal, 100)
        XCTAssertEqual(filtersEntity.getSelectedDateRangeGroupIndex(), 0)
        XCTAssertEqual(filtersEntity.getCardOperationType(), .payment)
        XCTAssertEqual(filtersEntity.getMovementType(), .income)
        XCTAssertEqual(filtersEntity.getTransactionDescription(), "test")
        
    }
    
}

extension TestCardTransactionFiltersViewModel: RegisterCommonDependenciesProtocol {
    var dependenciesResolver: DependenciesDefault {
        DependenciesDefault()
    }
}
