import Fuzi

public class ValidateUpdateSepaPayeeOTPParser: BSANParser<ValidateUpdateSepaPayeeOTPResponse, ValidateUpdateSepaPayeeOTPHandler> {
    override func setResponseData() {
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateUpdateSepaPayeeOTPHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
