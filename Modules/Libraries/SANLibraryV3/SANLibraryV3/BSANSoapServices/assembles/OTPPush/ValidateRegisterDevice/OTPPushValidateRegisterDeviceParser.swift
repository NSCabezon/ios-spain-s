import Foundation
import Fuzi

class OTPPushValidateRegisterDeviceParser: BSANParser<OTPPushValidateRegisterDeviceResponse, OTPPushValidateRegisterDeviceHandler> {
        
    override func setResponseData() {
        response.otpValidation = handler.otpValidation
    }
}

class OTPPushValidateRegisterDeviceHandler: BSANHandler {
    
    fileprivate var otpValidation: OTPValidationDTO?
    
    override func parseResult(result: XMLElement) throws {
        otpValidation = OTPValidationDTOParser.parse(result)
    }
}


