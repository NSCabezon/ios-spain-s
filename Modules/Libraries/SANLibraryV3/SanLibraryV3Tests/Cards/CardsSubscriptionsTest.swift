import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib
import SANLegacyLibrary

class CardsSubscriptionsTest: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.SUBSCRIPTIONS_CARDS)
        resetDataRepository()
        super.setUp()
        addMulMovHeader(["sanesp-pre.pru.bsch"])
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
 
    func testGetSubscriptionsList() {
        do {
            guard let card: CardDTO = getElementForTesting(orderInArray: 0, function: #function) else {
                return
            }
            let input = SubscriptionsListParameters(pan: card.formattedPAN,
                                                    clientType: "",
                                                    clientCode: "0",
                                                    dateFrom: "2019-01-01",
                                                    dateTo: "2021-05-20")
            let response = try bsanCardsManager!.getCardSubscriptionsList(input: input)
            guard let validData = try response.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validData, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetHistorical() {
        do {
            guard
                let card: CardDTO = getElementForTesting(orderInArray: 0, function: #function),
                let subscription = getSubscription(card)
            else {
                return
            }
            let inputHistorical = SubscriptionsHistoricalInputParams(pan: card.formattedPAN ?? "",
                                                                     instaId: subscription.instaId ?? "",
                                                                     startDate: "0001-01-01",
                                                                     endDate: "9999-12-31")
            let responseHistorical = try bsanCardsManager!.getCardSubscriptionsHistorical(input: inputHistorical)
            guard let historicalData = try responseHistorical.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: historicalData, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetGraphData() {
        do {
            guard
                let card: CardDTO = getElementForTesting(orderInArray: 0, function: #function),
                let subscription = getSubscription(card)
            else {
                return
            }
            let inputGraphic = SubscriptionsGraphDataInputParams(pan: card.formattedPAN ?? "",
                                                                 instaId: subscription.instaId ?? "")
            let responseGraphic = try bsanCardsManager!.getCardSubscriptionsGraphData(input: inputGraphic)
            guard let graphData = try responseGraphic.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: graphData, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func getSubscription(_ card: CardDTO) -> CardSubscriptionDTO? {
        let input = SubscriptionsListParameters(pan: card.formattedPAN,
                                                clientType: "",
                                                clientCode: "0",
                                                dateFrom: "2019-01-01",
                                                dateTo: "2021-05-20")
        let response = try? bsanCardsManager!.getCardSubscriptionsList(input: input)
        guard
            let subscriptionList = try? response?.getResponseData(),
            let subscriptions = subscriptionList.subscriptions
        else {
            return nil
        }
        return subscriptions[0]
    }
}
