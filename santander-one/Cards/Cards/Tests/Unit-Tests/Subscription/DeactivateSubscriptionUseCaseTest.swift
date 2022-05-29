import XCTest
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class DeactivateSubscriptionUseCaseTest: XCTestCase {
    var mockDataInjector = MockDataInjector()
    var dependenciesResolver = DependenciesDefault()

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
            let input = DeactivateSubscriptionInput(magicPhrase: "magicPhrase", instaID: "")
            let response = try getDeactivateSubscriptionUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSignPatternUseCase: throw")
        }
    }
}

private extension DeactivateSubscriptionUseCaseTest {
    func getDeactivateSubscriptionUseCase(_ input: DeactivateSubscriptionInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let useCase = DeactivateSubscriptionUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension DeactivateSubscriptionUseCaseTest: RegisterCommonDependenciesProtocol { }
