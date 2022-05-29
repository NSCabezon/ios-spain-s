import XCTest
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class IsM4MactiveSuscriptionEnabledUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    private var localConfigData: AppConfigDTOMock {
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData
    }
    
    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeFalse() {
        self.enableM4MNode(false)
        do {
            let response = try getIsM4MactiveSuscriptionEnabledUseCase()
            XCTAssertTrue(try !response.getOkResult().isM4MactiveSuscriptionEnabled)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeTrue() {
        self.enableM4MNode(true)
        do {
            let response = try getIsM4MactiveSuscriptionEnabledUseCase()
            XCTAssertTrue(try response.getOkResult().isM4MactiveSuscriptionEnabled)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension IsM4MactiveSuscriptionEnabledUseCaseTest {
    
    func getIsM4MactiveSuscriptionEnabledUseCase() throws -> UseCaseResponse<IsM4MactiveSuscriptionEnabledUseCaseOkOutput, StringErrorOutput> {
        let useCase = IsM4MactiveSuscriptionEnabledUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: ())
        return response
    }
    
    func enableM4MNode(_ enable: Bool) {
        self.mockDataInjector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            element: AppConfigDTOMock(defaultConfig: ["enabledM4MactiveSuscription" : "\(enable)"]))
    }
}

extension IsM4MactiveSuscriptionEnabledUseCaseTest: RegisterCommonDependenciesProtocol { }
