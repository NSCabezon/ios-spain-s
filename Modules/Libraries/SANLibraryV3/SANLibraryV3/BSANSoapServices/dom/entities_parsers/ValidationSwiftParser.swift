import Fuzi

class ValidationSwiftParser: DTOParser {
    public static func parse(_ node: XMLElement) -> ValidationSwiftDTO {
        var validationSwifDTO = ValidationSwiftDTO()
        
        if let settlementAmount = node.firstChild(tag: "importeLiqOrdenante"){
            validationSwifDTO.settlementAmountPayer = AmountDTOParser.parse(settlementAmount)
        }
        
        if let chargeAmount = node.firstChild(tag: "importeCargo"){
            validationSwifDTO.chargeAmount = AmountDTOParser.parse(chargeAmount)
        }
        
        if let accountType = node.firstChild(tag: "tipoCuenta"){
            validationSwifDTO.accountType = accountType.stringValue.trim()
        }
        
        if let modifyDate = node.firstChild(tag: "fechaModificada"){
            validationSwifDTO.modifyDate = DateFormats.safeDate(modifyDate.stringValue)
        }
        
        if let bic = node.firstChild(tag: "bicBeneficiario"){
            validationSwifDTO.beneficiaryBic = bic.stringValue.trim()
        }
        
        if let swiftIndicator = node.firstChild(tag: "indicadorSwift"){
            validationSwifDTO.swiftIndicator = swiftIndicator.stringValue.trim() == "S" ? true : false
        }
        
        return validationSwifDTO
    }
}
