import Foundation
import Fuzi

public class ValidateOTPPrepaidCardParser : BSANParser <ValidateOTPPrepaidCardResponse, ValidateOTPPrepaidCardHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateOTPPrepaidCardHandler: BSANHandler {
    
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
