import Fuzi

class ValidateMobileRechargeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ValidateMobileRechargeDTO {
        var validateMobileRechargeDTO = ValidateMobileRechargeDTO()
        
        if let posicionesFirmaToken = node.firstChild(css: "posicionesFirmaToken"){
            validateMobileRechargeDTO.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(posicionesFirmaToken)
        }
        
        if let saldoTotalDisponible = node.firstChild(css: "saldoTotalDisponible"){
            validateMobileRechargeDTO.availableAmount = AmountDTOParser.parse(saldoTotalDisponible)
        }
        
        if let titularTarjeta = node.firstChild(css: "titularTarjeta"){
            validateMobileRechargeDTO.holder = titularTarjeta.stringValue.trim()
        }
        
        if let descripcionTarjeta = node.firstChild(css: "descripcionTarjeta"){
            validateMobileRechargeDTO.cardDescription = descripcionTarjeta.stringValue.trim()
        }
        
        if let fechaCaducidad = node.firstChild(css: "fechaCaducidad"){
            validateMobileRechargeDTO.expirationDate = DateFormats.safeDate(fechaCaducidad.stringValue)
        }
        
        return validateMobileRechargeDTO
    }
}
