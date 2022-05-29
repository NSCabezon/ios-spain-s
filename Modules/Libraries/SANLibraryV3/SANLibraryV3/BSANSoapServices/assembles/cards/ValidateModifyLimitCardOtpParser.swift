import Fuzi

public class ValidateModifyLimitCardOtpParser : BSANParser<ValidateModifyLimitCardOtpResponse, ValidateModifyLimitCardOtpHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateModifyLimitCardOtpHandler: BSANHandler {
    
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
}

