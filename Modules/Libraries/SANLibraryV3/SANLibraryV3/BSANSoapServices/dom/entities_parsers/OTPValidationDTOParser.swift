import Fuzi

class OTPValidationDTOParser: DTOParser {
    
    struct Constants {
        let exceptedOtpNodeNames = ["exceptuado", "exceptuadoOTP", "clienteExceptuado", "usuarioExceptuado"]
    }
    
    public static func parse(_ node: XMLElement) -> OTPValidationDTO {
        var otpValidationDTO = OTPValidationDTO()
        
        if let token = node.firstChild(tag: "token"){
            otpValidationDTO.magicPhrase = token.stringValue.trim()
        }
        
        if let ticket = node.firstChild(tag: "ticket"){
            otpValidationDTO.ticket = ticket.stringValue.trim()
        } else if let ticket = node.firstChild(tag: "ticketOTP"){
            otpValidationDTO.ticket = ticket.stringValue.trim()
        }
        
        let first = Constants().exceptedOtpNodeNames.compactMap { node.firstChild(tag: $0) }.first
        otpValidationDTO.otpExcepted = DTOParser.safeBoolean(first?.stringValue.trim())
        
        return otpValidationDTO
    }
}
