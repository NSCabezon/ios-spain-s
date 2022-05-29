import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class MobileRechargeTest: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.MOBILE_RECHARGE_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testGetMobileOperators(){
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let response = try bsanMobileRechargeManager!.getMobileOperators(card: card)
            
            guard let mobileOperatorListDTO = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: mobileOperatorListDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateMobileRecharge(){
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let response = try bsanMobileRechargeManager!.validateMobileRecharge(card: card)
            
            guard let validateMobileRechargeDTO = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateMobileRechargeDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateMobileRechargeOTP(){
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let mobileOperatorResponse = try bsanMobileRechargeManager!.getMobileOperators(card: card)
            
            guard let mobileOperatorListDTO = try getResponseData(response: mobileOperatorResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validationResponse = try bsanMobileRechargeManager!.validateMobileRecharge(card: card)
            
            guard var validateMobileRechargeDTO = try getResponseData(response: validationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            validateMobileRechargeDTO.signatureWithTokenDTO?.signatureDTO?.values = ["2", "2", "2", "2"]
            
            guard let mobileOperatorDTO = mobileOperatorListDTO.mobileOperatorList?[0],
                let signatureWithTokenDTO = validateMobileRechargeDTO.signatureWithTokenDTO else {
                    return
            }
            
            let response = try bsanMobileRechargeManager!.validateMobileRechargeOTP(card: card, signature: signatureWithTokenDTO, mobile: FieldsUtils.MOBILE_RECHARGE_MOBIL, amount: FieldsUtils.amountDTO, mobileOperatorDTO: mobileOperatorDTO)
            
            guard let otpValidationDTO = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: otpValidationDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
