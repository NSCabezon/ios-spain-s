//

import XCTest
@testable import SanLibraryV3

class OperabilityChangeTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.eva)
        resetDataRepository()
        super.setUp()
    }

    func testValidateOTPOperabilityChange(){
        do{
            let validateChangeOperabilityResponse = try bsanSignatureManager!.validateSignatureActivation()
            let newOperabilityInd = "C"
            
            guard var validateOperabilityChange = try getResponseData(response: validateChangeOperabilityResponse) else {
                logTestError(errorMessage: "RETURNED NO VALIDATE OPERABILITY CHANGE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateOperabilityChange.signatureDTO)
            
            guard let getValidateOTPResponse = try bsanSignatureManager?.validateOTPOperability(newOperabilityInd: newOperabilityInd, signatureWithTokenDTO: validateOperabilityChange) else {
                logTestError(errorMessage: "RETURNED NO VALIDATE OTP DATA", function: #function)
                return
            }

            guard getValidateOTPResponse.isSuccess() else {
                logTestError(errorMessage: "RETURNED VALIDATE OTP UNSUCCESSFUL", function: #function)
                return
            }
            logTestSuccess(result: getValidateOTPResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmOTPOperabilityChange() {
        do{
            let validateChangeOperabilityResponse = try bsanSignatureManager!.validateSignatureActivation()
            let newOperabilityInd = "C"
            
            guard var validateOperabilityChange = try getResponseData(response: validateChangeOperabilityResponse) else {
                logTestError(errorMessage: "RETURNED NO VALIDATE OPERABILITY CHANGE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateOperabilityChange.signatureDTO)
            
            guard let getValidateOTPResponse = try bsanSignatureManager?.validateOTPOperability(newOperabilityInd: newOperabilityInd, signatureWithTokenDTO: validateOperabilityChange) else {
                logTestError(errorMessage: "RETURNED NO VALIDATE OTP DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateOperabilityChange.signatureDTO)

            let otpValidation = OTPValidationDTO(token: try? getValidateOTPResponse.getResponseData()?.token ?? "", ticket: try? getValidateOTPResponse.getResponseData()?.ticket ?? "", otpExcepted: true)
            
            guard let getConfirmOperabilityChangeResponse = try bsanSignatureManager?.confimOperabilityChange(newOperabilityInd: newOperabilityInd, otpValidationDTO: otpValidation, otpCode: "") else {
                logTestError(errorMessage: "RETURNED NO CONFIRM OPERABILITY CHANGE RESPONSE", function: #function)
                return
            }
            
            guard getConfirmOperabilityChangeResponse.isSuccess() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getValidateOTPResponse.isSuccess(), function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
