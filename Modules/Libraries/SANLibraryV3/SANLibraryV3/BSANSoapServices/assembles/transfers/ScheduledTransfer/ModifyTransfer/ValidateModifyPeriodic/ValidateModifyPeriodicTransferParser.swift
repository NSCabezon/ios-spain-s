import Foundation
import Fuzi

public class ValidateModifyPeriodicTransferParser : BSANParser<ValidateModifyPeriodicTransferResponse, ValidateModifyPeriodicTransferHandler> {
    override func setResponseData(){
        response.otpValidationDTO  = handler.otpValidationDTO
    }
}

public class ValidateModifyPeriodicTransferHandler: BSANHandler {
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        otpValidationDTO = OTPValidationDTOParser.parse(result)
    }
    
}
