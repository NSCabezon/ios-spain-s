import Foundation
import Fuzi

public class ValidateScaParser: BSANParser<ValidateScaResponse, ValidateScaHandler> {
        
    override func setResponseData() {
        response.validateScaDTO = handler.validateScaDTO
    }
}

public class ValidateScaHandler: BSANHandler {
    
    fileprivate var validateScaDTO: ValidateScaDTO?
    
    override func parseResult(result: XMLElement) throws {
        let tokenOTP: String? = result.firstChild(tag: "tokenOTP")?.stringValue.trim()
        let ticket: String? = result.firstChild(tag: "ticket")?.stringValue.trim()
        let deviceTelephone: String? = result.firstChild(tag: "numTfno_dispositivo")?.stringValue.trim()
        let telephone: String? = result.firstChild(tag: "numTfno")?.stringValue.trim()
        let via: SendViaSca? = SendViaSca(rawValue: result.firstChild(tag: "metodoEnvio")?.stringValue.trim() ?? "")
        let forwardingRemaining: Int?  = Int(result.firstChild(tag: "numReenOtpRes")?.stringValue.trim() ?? "")
        validateScaDTO = ValidateScaDTO(tokenOTP: tokenOTP, ticket: ticket, deviceTelephone: deviceTelephone, telephone: telephone, via: via, forwardingRemaining: forwardingRemaining)
    }
}
