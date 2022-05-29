import Fuzi

class ComunesDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ComunesDTO {
        var comunesDTO: ComunesDTO = ComunesDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "contratoID":
                    comunesDTO.contract = ContractDTOParser.parse(element)
                    break
                case "descContrato":
                    comunesDTO.descontrato = element.stringValue.trim()
                    break
                case "alias":
                    comunesDTO.alias = element.stringValue.trim()
                    break
                case "subtipoProd":
                    comunesDTO.productSubtype = ProductSubtypeDTOParser.parse(element)
                    break
                case "tipoInterv":
                    comunesDTO.tipoInterv = element.stringValue.trim()
                    break
                case "descTipoInterv":
                    comunesDTO.descTipoInterv = element.stringValue.trim()
                    break
                case "indVisibleAlias":
                    comunesDTO.indVisibleAlias = safeBoolean(element.stringValue)
                    break
                default:
                    BSANLogger.e("ComunesDTOParser", "Nodo Sin Parsear! -> \(tag) -> \(element.stringValue.trim())")
                    break
                }
            }
        }
        return comunesDTO
    }
    
}
