import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardsTestsPB: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.sabin)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }

//    func testLoadInactiveCardsRequest(){
//        
//        do{
//            
//            let loadInactiveCardsResponse = try bsanCardsManager!.loadInactiveCards(inactiveCardType: InactiveCardType.inactive)
//            
//            guard let _ = try getResponseData(response: loadInactiveCardsResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//            
//            let getCardDetailResponse = try bsanCardsManager!.getInactiveCardsMap()
//            
//            guard let cardDetail = try getResponseData(response: getCardDetailResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//            
//            logTestSuccess(result: cardDetail, function: #function)
//            
//        } catch let error{
//            logTestException(error: error, function: #function)
//        }
//    }
    
    func testGetCardDetailTokenRequest(){
        
        do{
            
            setUp(loginUser: LOGIN_USER.iñaki, pbToSet: nil)
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCardsManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let cardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: cardDetailToken, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidatePin(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCardsManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let cardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePINResponse = try bsanCardsManager!.validatePIN(cardDTO: card, cardDetailTokenDTO: cardDetailToken)

            guard let validatePIN = try getResponseData(response: validatePINResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validatePIN, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidatePinOTP(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCardsManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let cardDetailToken = try getCardDetailTokenResponse.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePINResponse = try bsanCardsManager!.validatePIN(cardDTO: card, cardDetailTokenDTO: cardDetailToken)
            
            guard var validatePIN = try getResponseData(response: validatePINResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validatePIN.signatureDTO)
                        
            let validatePINOTPResponse = try bsanCardsManager!.validatePINOTP(cardDTO: card, signatureWithTokenDTO: validatePIN)

            guard let validatePINOTP = try getResponseData(response:validatePINOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validatePINOTP, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
