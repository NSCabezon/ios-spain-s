import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetSubscriptionGraphDataUseCaseTest: XCTestCase {
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
        self.registerGraphData()
        let input = GetSubscriptionGraphDataUseCaseInput(pan: "5280930100005006", instaId: "testingMonthlyGraph001")
        do {
            let response = try getSubscriptionGraphDataUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSubscriptionGraphDataUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeError() {
        let input = GetSubscriptionGraphDataUseCaseInput(pan: "5280930100005006", instaId: "testingMonthlyGraph001")
        do {
            let response = try getSubscriptionGraphDataUseCase(input)
            let output = try? response.getOkResult()
            XCTAssertNil(output?.graphData)
        } catch {
            XCTFail("GetSubscriptionGraphDataUseCase: throw")
        }
    }
}

private extension GetSubscriptionGraphDataUseCaseTest {
    
    func registerGraphData() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardSubscriptionsGraphData,
            filename: "getCardSubscriptionsGraphList"
        )
    }
    
    func getSubscriptionGraphDataUseCase(_ input: GetSubscriptionGraphDataUseCaseInput) throws -> UseCaseResponse<GetSubscriptionGraphDataUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetSubscriptionGraphDataUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension GetSubscriptionGraphDataUseCaseTest: RegisterCommonDependenciesProtocol { }
