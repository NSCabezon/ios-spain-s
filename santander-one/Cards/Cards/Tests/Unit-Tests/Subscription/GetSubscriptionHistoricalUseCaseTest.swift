import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetSubscriptionHistoricalUseCaseTest: XCTestCase {
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
        self.registerSettlementDetail()
        let input = GetSubscriptionHistoricalUseCaseInput(pan: "5280930100005006",
                                                          instaId: "pruebaHistoricoMensualPayPal001",
                                                          startDate: "2019-01-01",
                                                          endDate: "2021-05-20")
        do {
            let response = try getSubscriptionHistoricalUseCase(input)
            let output = outputFrom(response)
            guard let subscriptions = output?.subscriptions else {
                return XCTFail("GetSubscriptionHistoricalUseCase: subscriptions is nil")
            }
            XCTAssertTrue(!subscriptions.isEmpty)
        } catch {
            XCTFail("GetSubscriptionHistoricalUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeError() {
        let input = GetSubscriptionHistoricalUseCaseInput(pan: "5280930100005006",
                                                          instaId: "pruebaHistoricoMensualPayPal001",
                                                          startDate: "2019-01-01",
                                                          endDate: "2021-05-20")
        do {
            let response = try getSubscriptionHistoricalUseCase(input)
            let output = outputFrom(response)
            XCTAssertNil(output?.subscriptions)
        } catch {
            XCTFail("GetSubscriptionHistoricalUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeOkAndShowsFractionableComponentIfNeeded() {
        self.registerSettlementDetail()
        let input = GetSubscriptionHistoricalUseCaseInput(pan: "5280930100005006",
                                                          instaId: "pruebaHistoricoMensualPayPal001",
                                                          startDate: "2019-01-01",
                                                          endDate: "2021-05-20")
        do {
            let response = try getSubscriptionHistoricalUseCase(input)
            let output = outputFrom(response)
            guard let subscriptions = output?.subscriptions else {
                return XCTFail("GetSubscriptionHistoricalUseCase: subscriptions is nil")
            }
            let isFractionable = subscriptions.filter({$0.isFractionable})
            XCTAssertTrue(!isFractionable.isEmpty)
        } catch {
            XCTFail("GetSubscriptionHistoricalUseCase: throw")
        }
    }
}

private extension GetSubscriptionHistoricalUseCaseTest {
    
    func registerSettlementDetail() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardSubscriptionsHistoricalList,
            filename: "cardSubscriptionsList"
        )
    }
    
    // MARK: Handle data
    func getSubscriptionHistoricalUseCase(_ input: GetSubscriptionHistoricalUseCaseInput) throws -> UseCaseResponse<GetSubscriptionHistoricalUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetSubscriptionHistoricalUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func outputFrom(_ response: UseCaseResponse<GetSubscriptionHistoricalUseCaseOkOutput, StringErrorOutput>) -> GetSubscriptionHistoricalUseCaseOkOutput? {
        let output = try? response.getOkResult()
        return output
    }
}

extension GetSubscriptionHistoricalUseCaseTest: RegisterCommonDependenciesProtocol { }
