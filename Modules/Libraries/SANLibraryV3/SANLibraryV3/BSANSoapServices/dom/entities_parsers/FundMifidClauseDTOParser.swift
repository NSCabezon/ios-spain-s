import Foundation
import Fuzi

class FundMifidClauseDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> FundMifidClauseDTO {
        var fundMifidClauseDTO = FundMifidClauseDTO()
        fundMifidClauseDTO.clauseDesc = ""
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "tipoExpediente":
                    fundMifidClauseDTO.fileTypeDTO = FileTypeDTOParser.parse(element)
                case "tipoClausula":
                    fundMifidClauseDTO.clauseType = InstructionStatusDTOParser.parse(element)
                case "clausulaProd":
                    fundMifidClauseDTO.prodClause = InstructionStatusDTOParser.parse(element)
                case "numLineas":
                    fundMifidClauseDTO.lineCount = DTOParser.safeInteger(element.stringValue.trim())
                default:
                    if element.tag?.starts(with: "clausula") == true {
                        fundMifidClauseDTO.clauseDesc = (fundMifidClauseDTO.clauseDesc ?? "") + element.stringValue.trim()
                        break
                    }
                    BSANLogger.e("FundMifidClauseDTOParser", "Nodo Sin Parsear! -> \(tag)")
                }
            }
        }
        
        return fundMifidClauseDTO
    }
}
