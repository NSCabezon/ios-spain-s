import XCTest
import CoreTestData
import CoreFoundationLib
import UnitTestCommons
import OpenCombine

@testable import Menu

class GetHomeTipsCountUseCaseTest: XCTestCase {

    private lazy var dependencies: TestPublicMenuDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector,
                                                homeTipsRepository: MockHomeTipsRepository())
        return TestPublicMenuDependenciesResolver(externalDependencies: external)
    }()

    private lazy var mockDataInjector: MockDataInjector = {
        return MockDataInjector()
    }()
    
    private lazy var menuRepository: PublicMenuRepository = {
        return PublicMenuRepositoryMock()
    }()

    private var availableTipsCount: Int = 0
    
    override func tearDownWithError() throws {
        menuRepository = PublicMenuRepositoryMock()
        availableTipsCount = 0
    }
    
    func test_When_TipsCountIsZero_Expect_RemoveGoToHomeTipsOption() throws {
        dependencies.external = TestExternalDependencies(injector: self.mockDataInjector,
                                                         homeTipsRepository: MockHomeTipsRepository(availableTipsCount))
        let sut = DefaultGetHomeTipsCountUseCase(dependencies: dependencies)
        let elems = try menuRepository.getPublicMenuConfiguration().sinkAwait()
        
        let newElems = try sut.filterHomeTipsElem(elems).sinkAwait()
        let containsGoToHomeTipsActions = newElems.contains { conf in
            conf.contains { $0.top?.action == .goToHomeTips || $0.bottom?.action == .goToHomeTips }
        }
        XCTAssert(containsGoToHomeTipsActions == false)
    }
    
    func test_When_TipsCountGreaterThanZero_Expect_MaintainGoToHomeTipsOption() throws {
        availableTipsCount = 3
        dependencies.external = TestExternalDependencies(injector: self.mockDataInjector,
                                                         homeTipsRepository: MockHomeTipsRepository(availableTipsCount))
        let sut = DefaultGetHomeTipsCountUseCase(dependencies: dependencies)
        let elems = try menuRepository.getPublicMenuConfiguration().sinkAwait()
        
        let newElems = try sut.filterHomeTipsElem(elems).sinkAwait()
        let containsGoToHomeTipsActions = newElems.contains { conf in
            conf.contains { $0.top?.action == .goToHomeTips || $0.bottom?.action == .goToHomeTips }
        }
        XCTAssert(containsGoToHomeTipsActions == true)
    }
}
