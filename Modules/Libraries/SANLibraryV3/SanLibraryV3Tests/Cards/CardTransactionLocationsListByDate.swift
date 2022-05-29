import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardTransactionLocationsListByDate: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.CARD_MAP_TRANSACTIONS)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testCardLocationsListByDate() {
        do{
            guard
                let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function),
                let startDate = DateFormats.toDate(string: "2020-03-17 00:00:00", output: DateFormats.TimeFormat.YYYYMMDD_HHmmss),
                let endDate = DateFormats.toDate(string: "2020-05-21 00:00:00", output: DateFormats.TimeFormat.YYYYMMDD_HHmmss)
            else{
                return
            }
            let response = try bsanCardsManager!.getCardTransactionLocationsListByDate(card: card, startDate: startDate, endDate: endDate)
            guard let transactionLocationsList = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: transactionLocationsList, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
