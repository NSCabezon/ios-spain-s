import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetSignPatternUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    
    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
        self.registerSettlementDetail()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeOk() {
        do {
            let response = try getGetSignPatternUseCase()
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension GetSignPatternUseCaseTest {
    
    func registerSettlementDetail() {
        self.mockDataInjector.register(
            for: \.bsanSignBasicData.getSignaturePattern,
            filename: "getSignaturePattern"
        )
    }
    
    func getGetSignPatternUseCase() throws -> UseCaseResponse<GetSignPatternUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetSignPatternUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: ())
        return response
    }
}

extension GetSignPatternUseCaseTest: RegisterCommonDependenciesProtocol { }
