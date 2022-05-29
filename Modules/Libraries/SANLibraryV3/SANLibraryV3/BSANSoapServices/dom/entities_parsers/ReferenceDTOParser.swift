import Foundation
import Fuzi

class ReferenceDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ReferenceDTO {
        
       var referenceDTO = ReferenceDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "referencia":
                    referenceDTO.reference = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("ReferenceDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return referenceDTO
    }
}
