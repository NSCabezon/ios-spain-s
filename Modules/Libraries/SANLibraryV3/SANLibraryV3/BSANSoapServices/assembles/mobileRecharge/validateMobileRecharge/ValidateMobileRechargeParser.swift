import Fuzi

public class ValidateMobileRechargeParser: BSANParser<ValidateMobileRechargeResponse, ValidateMobileRechargeHandler> {
    override func setResponseData() {
        response.validateMobileRechargeDTO = handler.validateMobileRechargeDTO
    }
}

public class ValidateMobileRechargeHandler: BSANHandler {
    var validateMobileRechargeDTO = ValidateMobileRechargeDTO()
    
    override func parseResult(result: XMLElement) throws {
        validateMobileRechargeDTO = ValidateMobileRechargeDTOParser.parse(result)
    }
}
