import Foundation
import Fuzi

public class ApplePayValidationParser: BSANParser<ApplePayValidationResponse, ApplePayValidationHandler> {
        
    override func setResponseData() {
        response.appleValidationDTO = handler.response
    }
}

public class ApplePayValidationHandler: BSANHandler {
    
    fileprivate var response: ApplePayValidationDTO?
    
    override func parseResult(result: XMLElement) throws {
        response = ApplePayValidationDTO(otp: OTPValidationDTOParser.parse(result))
    }
}


