import Fuzi

class MobileOperatorDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> MobileOperatorDTO {
        var mobileOperatorDTO = MobileOperatorDTO()
        
        if let nombre = node.firstChild(css: "nombre"){
            mobileOperatorDTO.name = nombre.stringValue.trim()
        }
        
        if let codigo = node.firstChild(css: "codigo"){
            mobileOperatorDTO.code = codigo.stringValue.trim()
        }
        
        if let importeMaximo = node.firstChild(css: "importeMaximo"){
            mobileOperatorDTO.maxAmount = AmountDTOParser.parse(importeMaximo)
        }
        
        if let importeMinimo = node.firstChild(css: "importeMinimo"){
            mobileOperatorDTO.minAmount = AmountDTOParser.parse(importeMinimo)
        }
        
        if let tramo = node.firstChild(css: "tramo"){
            mobileOperatorDTO.sectionAmount = AmountDTOParser.parse(tramo)
        }
        
        return mobileOperatorDTO
    }
}
