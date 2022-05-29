import Foundation
import Fuzi

class FundDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> FundDTO {
        var fundDTO = FundDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    fundDTO.contract = comunesDTO.contract
                    fundDTO.alias = comunesDTO.alias
                    fundDTO.contractDescription = comunesDTO.descontrato
                    fundDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    fundDTO.productSubtypeDTO = comunesDTO.productSubtype
                    fundDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "impValoracion":
                    fundDTO.valueAmount = AmountDTOParser.parse(element)
                    break
                case "impValoracionContravalor":
                    fundDTO.countervalueAmount = AmountDTOParser.parse(element)
                    break
                case "numParticipac":
                    fundDTO.sharesNumber = safeDecimal(element.stringValue)
                    break
                case "descSituacionContrato":
                    fundDTO.contractStatusDesc = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("FundDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return fundDTO
    }
    
    
    
}
