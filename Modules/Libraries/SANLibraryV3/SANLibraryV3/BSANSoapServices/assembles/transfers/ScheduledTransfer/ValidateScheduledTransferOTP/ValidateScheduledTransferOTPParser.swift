import Foundation
import Fuzi

public class ValidateScheduledTransferOTPParser : BSANParser<ValidateScheduledTransferOTPResponse, ValidateScheduledTransferOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateScheduledTransferOTPHandler: BSANHandler {
    
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        guard let tag = result.tag else { return }
        switch tag {
        case "methodResult":
            otpValidationDTO = OTPValidationDTOParser.parse(result)
            break
        default:
            BSANLogger.e("ValidateScheduledTransferOTPParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
