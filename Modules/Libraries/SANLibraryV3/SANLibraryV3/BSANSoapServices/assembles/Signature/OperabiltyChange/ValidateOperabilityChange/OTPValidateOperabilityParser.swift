import Foundation
import Fuzi

public class OTPValidateOperabilityParser: BSANParser<OTPValidateOperabilityResponse, OTPValidateOperabilityHandler> {
        
    override func setResponseData() {
        response.otpValidation = handler.otpValidation
    }
}

public class OTPValidateOperabilityHandler: BSANHandler {
        
    fileprivate var otpValidation = OTPValidationDTO()

    override func parseResult(result: XMLElement) throws {
        otpValidation = OTPValidationDTOParser.parse(result)
    }
}


