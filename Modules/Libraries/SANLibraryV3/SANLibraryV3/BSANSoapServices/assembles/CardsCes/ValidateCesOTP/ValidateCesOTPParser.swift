import Foundation
import Fuzi

public class ValidateCesOTPParser : BSANParser <ValidateCesOTPResponse, ValidateCesOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateCesOTPHandler: BSANHandler {

    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}

