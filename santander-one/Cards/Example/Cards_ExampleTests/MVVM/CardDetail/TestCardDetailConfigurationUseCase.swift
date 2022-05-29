import CoreTestData
import XCTest
@testable import Cards

class GetCardDetailConfigurationUseCaseTest: XCTestCase {
    lazy var dependencies: TestCardDetailDependencies = {
        let external = TestCardDetailExternalDependencies(injector: self.mockDataInjector)
        return TestCardDetailDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_When_FetchConfiguration_Expect_ShowCardPANIsEnabled() throws {
        let sut = DefaultGetCardDetailConfigurationUseCase()
        
        let config = try sut.fetchCardDetailConfiguration(card: MockCard()).sinkAwait()
        XCTAssert(config.isShowCardPAN == false)
    }
    
    func test_When_FetchConfiguration_Expect_HolderIsEnabled() throws {
        let sut = DefaultGetCardDetailConfigurationUseCase()
        
        let config = try sut.fetchCardDetailConfiguration(card: MockCard()).sinkAwait()
        XCTAssert(config.isCardHolderEnabled == true)
    }
  
}

