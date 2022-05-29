import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class SignaturesTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.eva)
        resetDataRepository()
        super.setUp()
    }
    
    func testValidateSignatureActivation(){
        
        do{
            
            let validateSignatureActivationResponse = try bsanSignatureManager!.validateSignatureActivation()
            
            guard let validateSignatureActivation = try getResponseData(response: validateSignatureActivationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateSignatureActivation, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmSignatureActivation(){
        
        do{
            
            let _ = try bsanSignatureManager?.loadCMCSignature()
            let getCMCResponse = try bsanSignatureManager!.getCMCSignature()
            guard let signStatusInfo = try getResponseData(response: getCMCResponse) else{
                logTestError(errorMessage: "NO SIGNSTATUSINFO", function: #function)
                return
            }
            
            var signatureDTO = signStatusInfo.signatureDataDTO.signatureDTO
            TestUtils.fillSignature(input: &signatureDTO)
            
            let validateSignatureActivationResponse = try bsanSignatureManager!.confirmSignatureActivation(newSignature: FieldsUtils.NEW_SIGNATURE, signatureDTO: signatureDTO!)
            
            guard let validateSignatureActivation = try getResponseData(response: validateSignatureActivationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateSignatureActivation, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testChangePassword(){
        
        do{
            
            guard let sessionData = getSessionData() else {
                logTestError(errorMessage: "NO SESSION DATA", function: #function)
                return
            }
            
            if sessionData.globalPositionDTO.userDataDTO == nil{
                logTestError(errorMessage: "NO USER DATA", function: #function)
                return
            }
            
            let cipherKeys = CipherKeys(userDataDTO: sessionData.globalPositionDTO.userDataDTO!)
            
            let changePasswordResponse = try bsanSignatureManager!.changePassword(oldPassword: cipherKeys.getCipherKeys(keyNoCipher: FieldsUtils.OLD_ACCESS_PASSWORD) ?? "", newPassword: cipherKeys.getCipherKeys(keyNoCipher: FieldsUtils.NEW_ACCESS_PASSWORD) ?? "")
            
            guard let changePassword = try getResponseData(response: changePasswordResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: changePassword, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmSignatureChange(){
        
        do{
            
            let _ = try bsanSignatureManager?.loadCMCSignature()
            let getCMCResponse = try bsanSignatureManager!.getCMCSignature()
            guard let signStatusInfo = try getResponseData(response: getCMCResponse) else{
                logTestError(errorMessage: "NO SIGNSTATUSINFO", function: #function)
                return
            }
            
            var signatureDTO = signStatusInfo.signatureDataDTO.signatureDTO
            TestUtils.fillSignature(input: &signatureDTO)
            
            let confirmSignatureChangeResponse = try bsanSignatureManager?.confirmSignatureChange(newSignature: FieldsUtils.NEW_SIGNATURE, signatureDTO: signatureDTO!)
            
            if confirmSignatureChangeResponse == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let confirmSignatureChange = try getResponseData(response: confirmSignatureChangeResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmSignatureChange, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
}
