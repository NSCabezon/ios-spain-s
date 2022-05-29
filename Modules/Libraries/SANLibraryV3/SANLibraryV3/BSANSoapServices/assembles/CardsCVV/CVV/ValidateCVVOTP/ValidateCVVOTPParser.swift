import Foundation
import Fuzi

public class ValidateCVVOTPParser : BSANParser <ValidateCVVOTPResponse, ValidateCVVOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateCVVOTPHandler: BSANHandler {

    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
