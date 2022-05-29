import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class ActivateSubscriptionUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()

    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeOk() {
        do {
            let input = ActivateSubscriptionInput(magicPhrase: "magicPhrase",
                                                  instaID: "instaID")
            let response = try getActivateSubscriptionUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeKo() {
        do {
            let input = ActivateSubscriptionInput(magicPhrase: "", instaID: "instaID")
            let response = try getActivateSubscriptionUseCase(input)
            XCTAssertFalse(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension ActivateSubscriptionUseCaseTest {
    func getActivateSubscriptionUseCase(_ input: ActivateSubscriptionInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let useCase = ActivateSubscriptionUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension ActivateSubscriptionUseCaseTest: RegisterCommonDependenciesProtocol { }
