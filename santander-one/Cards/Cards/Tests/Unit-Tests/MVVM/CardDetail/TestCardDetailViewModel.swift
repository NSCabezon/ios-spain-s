import Foundation
import XCTest
import UnitTestCommons
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class TestCardDetailViewModel: XCTestCase {
    lazy var dependencies: TestCardDetailDependencies = {
        let external = TestCardDetailExternalDependencies(injector: self.mockDataInjector)
        return TestCardDetailDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    lazy var dependenciesExternal = TestCardDetailExternalDependencies(injector: mockDataInjector)
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.injectMockCardData()
        return injector
    }()
    
    private let mockCard = MockCard()
    private let mockDetail = MockCardDetail()

}

extension TestCardDetailViewModel {
    
    func test_NotCardDetailLoaded_When_ViewDidLoad() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
             
        sut.viewDidLoad()
        
        XCTAssertFalse(self.dependencies.mockCardDetailConfigurationUseCase.getCardDetailConfigUseCaseCalled)
        XCTAssertFalse(self.dependencies.mockCardDetailUseCase.getCardDetailUseCaseCalled)
        XCTAssertFalse(self.dependenciesExternal.mockExpensesUseCase.mockExpensesCalled)
    }
    
    func test_BindingdCardDetail_When_ViewDidLoad_WiththoutConfiguration() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
             
        let trigger = {
            sut.dataBinding.set(self.mockCard)
            sut.viewDidLoad()
        }
        
        let _ = try sut.state
            .case ( CardDetailState.dataLoaded )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.calculateExpenses )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.configurationLoaded )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.cardDetailLoaded )
            .sinkAwait(beforeWait: trigger)
        

        XCTAssertTrue(self.dependencies.mockCardDetailUseCase.getCardDetailUseCaseCalled)
        XCTAssertFalse(self.dependenciesExternal.mockExpensesUseCase.mockExpensesCalled)
    }
    
    func test_BindingCardDetail_When_ViewDidLoad() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
             
        let trigger = {
            sut.dataBinding.set(self.mockCard)
            sut.viewDidLoad()
        }
        
        let _ = try sut.state
            .case ( CardDetailState.dataLoaded )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.calculateExpenses )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.configurationLoaded )
            .sinkAwait(beforeWait: trigger)
        
        let _ = try sut.state
            .case ( CardDetailState.cardDetailLoaded )
            .sinkAwait(beforeWait: trigger)

        XCTAssertTrue(self.dependencies.mockCardDetailUseCase.getCardDetailUseCaseCalled)
        XCTAssertFalse(self.dependenciesExternal.mockExpensesUseCase.mockExpensesCalled)
    }
    
    func test_ShowPANCoordinator() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
        
        sut.dataBinding.set(self.mockCard)
        sut.viewDidLoad()
             
        sut.didTapOnShowPAN()
        
        XCTAssertTrue(self.dependencies.mockCoordinator.showPANCalled)
    }
    func test_ActiveCardCoordinator() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
        
        sut.dataBinding.set(self.mockCard)
        sut.viewDidLoad()
             
        sut.didSelectActiveCard()
        
        XCTAssertTrue(self.dependencies.mockCoordinator.activeCardCalled)
    }
    
    func test_MenuCoordinator() throws {
        let sut = CardDetailViewModel(dependencies: dependencies)
             
        sut.didSelectOpenMenu()
        
        XCTAssertTrue(self.dependencies.mockCoordinator.openMenuCalled)
    }
}

extension TestCardDetailViewModel: RegisterCommonDependenciesProtocol {
    var dependenciesResolver: DependenciesDefault {
        DependenciesDefault()
    }
}
