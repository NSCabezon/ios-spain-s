import Foundation
import Fuzi

class LiquidationDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> LiquidationDTO {
        var liquidationDTO = LiquidationDTO()
        
        if let fechaComienzoValidez = node.firstChild(tag: "fechaComienzoValidez"){
            liquidationDTO.validityOpeningDate = DateFormats.safeDate(fechaComienzoValidez.stringValue)
        }
        
        if let fechaFinValidez = node.firstChild(tag: "fechaFinValidez"){
            liquidationDTO.validityClosingDate = DateFormats.safeDate(fechaFinValidez.stringValue)
        }
        
        if let importeLiq = node.firstChild(tag: "importeLiq"){
            liquidationDTO.settlementAmount = AmountDTOParser.parse(importeLiq)
        }
        
        return liquidationDTO
    }
}
