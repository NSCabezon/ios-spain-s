import Fuzi

class SanKeyOTPValidationDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SanKeyOTPValidationDTO {
        let tokenStep = node.firstChild(tag: "tokenPasos")?.stringValue.trim()
        let otpValidationDTO = OTPValidationDTOParser.parse(node)
        let fingerPrintFlag = node.firstChild(tag: "indicadorHuella")?.stringValue.trim().lowercased()
        return SanKeyOTPValidationDTO(tokenSteps: tokenStep,
                                      fingerPrintFlag: fingerPrintFlag == "s" ? .biometry : .signature,
                                      otpValidationDTO: otpValidationDTO)
    }
}
