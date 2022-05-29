import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class StartSignPatternUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()

    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
        self.registerSignBasic()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeOk() {
        do {
            let input = StartSignPatternInput(pattern: "SIGN01", instaID: "pruebaHistoricoMensualSpotify001")
            let response = try getStartSignPatternUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension StartSignPatternUseCaseTest {

    func registerSignBasic() {
        self.mockDataInjector.register(
            for: \.bsanSignBasicData.getSignBasicOperation,
            filename: "getSignBasicOperation"
        )
    }

    func getStartSignPatternUseCase(_ input: StartSignPatternInput) throws -> UseCaseResponse<StartSignPatternUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let useCase = StartSignPatternUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension StartSignPatternUseCaseTest: RegisterCommonDependenciesProtocol { }
