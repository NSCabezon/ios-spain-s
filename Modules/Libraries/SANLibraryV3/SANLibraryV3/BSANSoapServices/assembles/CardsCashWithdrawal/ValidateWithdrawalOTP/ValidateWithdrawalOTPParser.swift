import Foundation
import Fuzi

public class ValidateWithdrawalOTPParser : BSANParser <ValidateWithdrawalOTPResponse, ValidateWithdrawalOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateWithdrawalOTPHandler: BSANHandler {

    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}

