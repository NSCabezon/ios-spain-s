import Foundation
import Fuzi

class DepositDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> DepositDTO {
        var depositDTO = DepositDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    depositDTO.contract = comunesDTO.contract
                    depositDTO.alias = comunesDTO.alias
                    depositDTO.contractDescription = comunesDTO.descontrato
                    depositDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    depositDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "impSaldoActual":
                    depositDTO.balance = AmountDTOParser.parse(element)
                    break
                case "impSaldoActualContravalor":
                    depositDTO.countervalueCurrentBalance = AmountDTOParser.parse(element)
                    break
                case "titular":
                    depositDTO.client = ClientDTOParser.parse(element)
                    break
                case "descSituacionContrato":
                    depositDTO.contractSituationDesc = element.stringValue.trim()
                default:
                    BSANLogger.e("DepositDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return depositDTO
    }
    
    
    
}
