import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetSubscriptionsListUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    override func setUp() {
        super.setUp()
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setupCommonsDependencies()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeOk() {
        self.registerSettlementDetail()
        let input = SubscriptionsListInput(pan: "5280930100005006", dateFrom: "2019-01-01", dateTo: "2021-05-20")
        do {
            let response = try getSubscriptionsListUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("GetSubscriptionsListUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeError() {
        let input = SubscriptionsListInput(pan: "5280930100005006", dateFrom: "2019-01-01", dateTo: "2021-05-20")
        do {
            let response = try getSubscriptionsListUseCase(input)
            XCTAssertFalse(response.isOkResult)
        } catch {
            XCTFail("GetSubscriptionsListUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeOkWithFractionableItems() {
        self.registerSettlementDetail()
        let input = SubscriptionsListInput(pan: "5280930100005006", dateFrom: "2019-01-01", dateTo: "2021-05-20")
        do {
            let response = try getSubscriptionsListUseCase(input)
            guard let subscriptions = try? response.getOkResult() else {
                return XCTFail("GetSubscriptionsListUseCase: subscriptions is empty")
            }
            let filteredFractionableList = subscriptions.subscriptions
                .filter({$0.isFractionable})
            XCTAssertTrue(!filteredFractionableList.isEmpty)
        } catch {
            XCTFail("GetSubscriptionsListUseCase: throw")
        }
    }
}

private extension GetSubscriptionsListUseCaseTest {
    
    func registerSettlementDetail() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardSubscriptionsList,
            filename: "getCardSubscriptionsList"
        )
    }
    
    // MARK: Handle data
    func getSubscriptionsListUseCase(_ input: SubscriptionsListInput) throws -> UseCaseResponse<SubscriptionsListUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetSubscriptionsListUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}

extension GetSubscriptionsListUseCaseTest: RegisterCommonDependenciesProtocol { }
