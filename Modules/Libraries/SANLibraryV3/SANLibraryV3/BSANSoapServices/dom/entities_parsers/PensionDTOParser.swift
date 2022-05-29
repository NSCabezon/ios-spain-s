import Foundation
import Fuzi

class PensionDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PensionDTO {
        var pensionDTO = PensionDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    pensionDTO.contract = comunesDTO.contract
                    pensionDTO.alias = comunesDTO.alias
                    pensionDTO.contractDescription = comunesDTO.descontrato
                    pensionDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    pensionDTO.productSubtypeDTO = comunesDTO.productSubtype
                    pensionDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "impValoracion":
                    pensionDTO.valueAmount = AmountDTOParser.parse(element)
                    break
                case "impValoracionContravalor":
                    pensionDTO.counterValueAmount = AmountDTOParser.parse(element)
                    break
                case "numParticipac":
                    pensionDTO.sharesNumber = safeDecimal(element.stringValue)
                    break
                case "descSituacionContrato":
                    pensionDTO.contractStatusDesc = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("PensionDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return pensionDTO
    }
    
    
    
}
