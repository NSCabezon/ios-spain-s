import Foundation
import Fuzi

public class ConfirmScaParser: BSANParser<ConfirmScaResponse, ConfirmScaHandler> {
        
    override func setResponseData() {
        response.confirmScaDTO = handler.confirmScaDTO
    }
}

public class ConfirmScaHandler: BSANHandler {
    
    fileprivate var confirmScaDTO: ConfirmScaDTO?
    
    override func parseResult(result: XMLElement) throws {
        let otpOkIndicator: String? = result.firstChild(tag: "indOTPOK")?.stringValue.trim()
        let penalizeScaIndicator: String? = result.firstChild(tag: "indPenaSca")?.stringValue.trim()
        let otpValIndicator: String? = result.firstChild(tag: "indValOTP")?.stringValue.trim()
        confirmScaDTO = ConfirmScaDTO(otpOkIndicator: otpOkIndicator, penalizeScaIndicator: penalizeScaIndicator, otpValIndicator: otpValIndicator)
    }
}


