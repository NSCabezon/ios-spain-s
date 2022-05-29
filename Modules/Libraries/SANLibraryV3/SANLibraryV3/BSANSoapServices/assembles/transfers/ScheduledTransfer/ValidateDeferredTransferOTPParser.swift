import Foundation
import Fuzi

public class ValidateDeferredTransferOTPParser : BSANParser<ValidateDeferredTransferOTPResponse, ValidateDeferredTransferOTPHandler> {
    override func setResponseData(){
        response.otpValidationDTO = handler.otpValidationDTO
    }
}

public class ValidateDeferredTransferOTPHandler: BSANHandler {
    
    var otpValidationDTO = OTPValidationDTO()
    
    override func parseResult(result: XMLElement) throws {
        guard let tag = result.tag else { return }
        switch tag {
        case "methodResult":
            otpValidationDTO = OTPValidationDTOParser.parse(result)
            break
        default:
            BSANLogger.e("ValidateDeferredTransferOTPParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
