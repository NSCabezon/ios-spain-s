import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CesTests: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.superSpeedCardServiceUser2)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testConsultCesSignaturePositions(){
        
        do{
            
            let consultCesSignaturePositionsResponse = try bsanSignatureManager!.consultPensionSignaturePositions()
            
            guard let consultCesSignaturePositions = try getResponseData(response: consultCesSignaturePositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: consultCesSignaturePositions, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConsultWithdrawal(){
        
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let consultPensionSignaturePositionsResponse = try bsanSignatureManager!.consultCashWithdrawalSignaturePositions()
            
            guard var consultPensionSignaturePositions = try getResponseData(response: consultPensionSignaturePositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &consultPensionSignaturePositions.signatureDTO)
            
            let getHistoricalWithdrawalResponse = try bsanCashWithdrawalManager!.getHistoricalWithdrawal(cardDTO: card, signatureWithTokenDTO: consultPensionSignaturePositions)
            
            logTestSuccess(result: getHistoricalWithdrawalResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateCVVOTP(){
        
        do{
            
            let consultCesSignaturePositionsResponse = try bsanSignatureManager!.consultPensionSignaturePositions()
            
            guard var consultCesSignaturePositions = try getResponseData(response: consultCesSignaturePositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
            if consultCesSignaturePositions.signatureDTO == nil{
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &consultCesSignaturePositions.signatureDTO)
            
            let validateOTPResponse = try bsanCesManager!.validateOTP(cardDTO: card, signatureWithTokenDTO: consultCesSignaturePositions, phone: "659581738")
            
            guard let validateOTP = try getResponseData(response: validateOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateOTP, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmCVVOTP(){
        
        do{
            
            let consultCesSignaturePositionsResponse = try bsanSignatureManager!.consultPensionSignaturePositions()
            
            guard var consultCesSignaturePositions = try getResponseData(response: consultCesSignaturePositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
            if consultCesSignaturePositions.signatureDTO == nil{
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &consultCesSignaturePositions.signatureDTO)
            
            let validateOTPResponse = try bsanCesManager!.validateOTP(cardDTO: card, signatureWithTokenDTO: consultCesSignaturePositions, phone: "659581738")
            
            guard let validateOTP = try getResponseData(response: validateOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanCesManager!.confirmOTP(cardDTO: card, otpValidationDTO: validateOTP, otpCode: "23")
            
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
