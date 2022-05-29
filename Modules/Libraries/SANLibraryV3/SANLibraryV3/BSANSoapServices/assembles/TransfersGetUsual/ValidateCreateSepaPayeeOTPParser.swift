import Fuzi

public class ValidateCreateSepaPayeeOTPParser: BSANParser<ValidateCreateSepaPayeeOTPResponse, ValidateCreateSepaPayeeOTPHandler> {
    override func setResponseData() {
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateCreateSepaPayeeOTPHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
