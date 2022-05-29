import Foundation
import Fuzi

class CardDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> CardDTO {
        var cardDTO = CardDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    cardDTO.contract = comunesDTO.contract
                    cardDTO.alias = comunesDTO.alias
                    cardDTO.contractDescription = comunesDTO.descontrato
                    cardDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    cardDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "pan":
                    cardDTO.PAN = element.stringValue.trim()
                    break
                case "descTipoTarjeta":
                    cardDTO.cardTypeDescription = element.stringValue.trim()
                    break
                case "descSituacionContratoTarjeta":
                    cardDTO.cardContractStatusType = CardContractStatusType.parse(element.stringValue.trim())
                    break
                case "permiteDineroDirecto":
                    cardDTO.allowsDirectMoney = safeBoolean(element.stringValue)
                    break
                case "indECashPrepago":
                    cardDTO.eCashInd = safeBoolean(element.stringValue)
                    break
                case "subtipoProd":
                    cardDTO.productSubtypeDTO = ProductSubtypeDTOParser.parse(element)
                    break
                case "tipoInterv":
                    cardDTO.ownershipType = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("CardDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return cardDTO
    }
}
