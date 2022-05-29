//

import Foundation
import Fuzi

public class ValidationOTPNoSEPAParser : BSANParser<ValidationOTPNoSEPAResponse, ValidationOTPNoSEPAHandler> {
    override func setResponseData(){
        response.otpValidationDTO  = handler.otpValidationDTO
    }
}

public class ValidationOTPNoSEPAHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
    
}
