import Foundation
import Fuzi

public class ValidateGenericTransferOTPParser : BSANParser <ValidateGenericTransferOTPResponse, ValidateGenericTransferOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateGenericTransferOTPHandler: BSANHandler {
    
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
