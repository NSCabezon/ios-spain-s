import Foundation
import Fuzi

class StockAccountDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockAccountDTO {
        var stockAccountDTO = StockAccountDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    stockAccountDTO.contract = comunesDTO.contract
                    stockAccountDTO.alias = comunesDTO.alias
                    stockAccountDTO.contractDescription = comunesDTO.descontrato
                    stockAccountDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    stockAccountDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "impValoracion":
                    stockAccountDTO.valueAmount = AmountDTOParser.parse(element)
                    break
                case "impValoracionContravalor":
                    stockAccountDTO.countervalueAmount = AmountDTOParser.parse(element)
                    break
                case "codReferencia":
                    stockAccountDTO.referenceCode = element.stringValue.trim()
                default:
                    BSANLogger.e("StockAccountDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return stockAccountDTO
    }
    
    
    
}
