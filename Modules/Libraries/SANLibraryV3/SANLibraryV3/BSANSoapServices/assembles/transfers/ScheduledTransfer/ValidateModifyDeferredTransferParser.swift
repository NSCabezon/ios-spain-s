import Foundation
import Fuzi

public class ValidateModifyDeferredTransferParser : BSANParser<ValidateModifyDeferredTransferResponse, ValidateModifyDeferredTransferHandler> {
    override func setResponseData(){
        response.otpValidationDTO  = handler.otpValidationDTO
    }
}

public class ValidateModifyDeferredTransferHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
    
}
