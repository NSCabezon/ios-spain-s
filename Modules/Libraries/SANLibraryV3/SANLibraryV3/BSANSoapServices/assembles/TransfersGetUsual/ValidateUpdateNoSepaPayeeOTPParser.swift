import Foundation
import Fuzi

public class ValidateUpdateNoSepaPayeeOTPParser: BSANParser<ValidateUpdateNoSepaPayeeOTPResponse, ValidateUpdateNoSepaPayeeOTPHandler> {
        
    override func setResponseData() {
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateUpdateNoSepaPayeeOTPHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}


