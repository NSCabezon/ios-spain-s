import Fuzi

public class ValidateMobileRechargeOTPParser: BSANParser<ValidateMobileRechargeOTPResponse, ValidateMobileRechargeOTPHandler> {
    override func setResponseData() {
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateMobileRechargeOTPHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}
