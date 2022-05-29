import Foundation
import Fuzi

public class ValidateCreateNoSepaPayeeOTPParser: BSANParser<ValidateCreateNoSepaPayeeOTPResponse, ValidateCreateNoSepaPayeeOTPHandler> {
        
    override func setResponseData() {
         response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateCreateNoSepaPayeeOTPHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}


