import Foundation
import Fuzi

class LiquidationItemDetailDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> LiquidationItemDetailDTO {
        var liquidationItemDetailDTO = LiquidationItemDetailDTO()
        
        if let comunes = node.firstChild(tag: "comunes"){
            if let fechaComienzoValidez = comunes.firstChild(tag: "fechaComienzoValidez"){
                liquidationItemDetailDTO.validityOpeningDate = DateFormats.safeDate(fechaComienzoValidez.stringValue)
            }
            if let fechaFinValidez = comunes.firstChild(tag: "fechaFinValidez"){
                liquidationItemDetailDTO.validityClosingDate = DateFormats.safeDate(fechaFinValidez.stringValue)
            }
            if let importeLiq = comunes.firstChild(tag: "importeLiq"){
                liquidationItemDetailDTO.settlementAmount = AmountDTOParser.parse(importeLiq)
            }
        }
        
        if let tasaLiquidacion = node.firstChild(tag: "tasaLiquidacion"){
            liquidationItemDetailDTO.liquidationFee = DTOParser.safeDecimal(tasaLiquidacion.stringValue.trim())
        }
        
        if let descripcionLiquidacion = node.firstChild(tag: "descripcionLiquidacion"){
            liquidationItemDetailDTO.liquidationDescription = descripcionLiquidacion.stringValue.trim()
        }
        
        return liquidationItemDetailDTO
    }
}
