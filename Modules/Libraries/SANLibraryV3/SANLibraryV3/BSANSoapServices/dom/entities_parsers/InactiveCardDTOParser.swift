import Foundation
import Fuzi

class InactiveCardDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> InactiveCardDTO {
        var inactiveCardDTO = InactiveCardDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "numeroTarj":
                    inactiveCardDTO.PAN = element.stringValue.trim()
                    break
                case "contratoTarjeta":
                    inactiveCardDTO.contract = ContractDTOParser.parse(element)
                case "descTarjeta":
                    inactiveCardDTO.cardDescription = element.stringValue.trim()
                    break
                case "descContratoTarjeta":
                    inactiveCardDTO.cardContractDescription = element.stringValue.trim()
                    break
                case "fechaCaducidad":
                    inactiveCardDTO.expirationDate = DateFormats.safeDate(element.stringValue)
                    break
                default:
                    BSANLogger.e("InactiveCardDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return inactiveCardDTO
    }
}
