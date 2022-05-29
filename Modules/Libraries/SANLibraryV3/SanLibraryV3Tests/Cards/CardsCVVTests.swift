import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardsCVVTests: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.sabin)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testValidateCVV(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCardsManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)

            guard let getCardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateCVVResponse = try bsanCardsManager!.validateCVV(cardDTO: card)
            
            guard let validateCVV = try getResponseData(response: validateCVVResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateCVV, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateCVVOTP(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
                        
            let validateCVVResponse = try bsanCardsManager!.validateCVV(cardDTO: card)
            
            guard let validateCVV = try getResponseData(response: validateCVVResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let signatureWithToken = validateCVV as? SignatureWithTokenDTO else {
                return
            }
            let validateCVVOTPResponse = try bsanCardsManager!.validateCVVOTP(cardDTO: card, signatureWithTokenDTO: signatureWithToken)
            guard let validateCVVOTP = try getResponseData(response: validateCVVOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validateCVVOTP, function: #function)            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
