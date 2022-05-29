import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CashWithdrawalTests: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.superSpeedCardServiceUser2)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testGetCardDetailToken(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCashWithdrawalManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let getCardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getCardDetailToken, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidatePIN(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCashWithdrawalManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let getCardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePINResponse = try bsanCashWithdrawalManager!.validatePIN(cardDTO: card, cardDetailTokenDTO: getCardDetailToken)
            
            guard let validatePIN = try getResponseData(response: validatePINResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validatePIN, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateOTP(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCashWithdrawalManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let getCardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePINResponse = try bsanCashWithdrawalManager!.validatePIN(cardDTO: card, cardDetailTokenDTO: getCardDetailToken)
            
            guard var validatePIN = try getResponseData(response: validatePINResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if validatePIN.signatureDTO == nil{
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validatePIN.signatureDTO)
            
            let validateOTPResponse = try bsanCashWithdrawalManager!.validateOTP(cardDTO: card, signatureWithTokenDTO: validatePIN)
            
            guard let validateOTP = try getResponseData(response: validateOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanCashWithdrawalManager!.confirmOTP(cardDTO: card, otpValidationDTO: validateOTP, otpCode: "23", amount: AmountDTO(value: 100.0, currency: CurrencyDTO(currencyName: "EUR", currencyType: .eur)), trusteerInfo: nil)
            
            guard let confirmOTP = try getResponseData(response: confirmOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmOTP, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
