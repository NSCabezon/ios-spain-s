import Foundation
import Fuzi

class FileTypeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> FileTypeDTO {
        var fileTypeDTO = FileTypeDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "tipoExpediente":
                    fileTypeDTO.fileTypeMifid = InstructionStatusDTOParser.parse(element)
                case "tipoClausula":
                    fileTypeDTO.fileSequenceCode = element.stringValue.trim()
                default:
                    BSANLogger.e("FileTypeDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return fileTypeDTO
    }
}
