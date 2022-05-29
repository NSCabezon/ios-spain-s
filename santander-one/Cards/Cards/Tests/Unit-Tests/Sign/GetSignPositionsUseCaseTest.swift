import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetSignPositionsUseCaseTest: XCTestCase {
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
            let input = BasicSignValidationInput(magicPhrase: "")
            let response = try getGetSignPositionsUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension GetSignPositionsUseCaseTest {

    func registerSignBasic() {
        self.mockDataInjector.register(
            for: \.bsanSignBasicData.getSignBasicOperation,
            filename: "getSignBasicOperation"
        )
        self.mockDataInjector.register(
            for: \.bsanSignBasicData.getContractCmc,
            filename: "getContractCMC"
        )
    }
    
    func getGetSignPositionsUseCase(_ input: BasicSignValidationInput) throws -> UseCaseResponse<BasicSignValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let useCase = BasicSignValidationUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension GetSignPositionsUseCaseTest: RegisterCommonDependenciesProtocol { }
