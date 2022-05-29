import Foundation
import Fuzi

class ReferenceStandardDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ReferenceStandardDTO {
        var referenceStandardDTO = ReferenceStandardDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "SUBTIPO_DE_PRODUCTO":
                    referenceStandardDTO.productSubtypeDTO = ProductSubtypeDTOParser.parse(element)
                    break
                case "CODIGO_DE_ESTANDAR":
                    referenceStandardDTO.standardCode = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("ReferenceStandardDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return referenceStandardDTO
    }
}
