import Foundation
import Fuzi

class IdActuantePayeeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> IdActuantePayeeDTO {
        var idActuantePayeeDTO = IdActuantePayeeDTO()
        idActuantePayeeDTO.actingNumber = node.firstChild(tag:"NUMERO_DE_ACTUANTE")?.stringValue.trim()
        if let actingTypeNode = node.firstChild(tag:"TIPO_DE_ACTUANTE"){
            idActuantePayeeDTO.bankCode = actingTypeNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
            idActuantePayeeDTO.actingTypeCode = actingTypeNode.firstChild(tag:"COD_TIPO_DE_ACTUANTE")?.stringValue.trim()
        }
        return idActuantePayeeDTO
    }
}
