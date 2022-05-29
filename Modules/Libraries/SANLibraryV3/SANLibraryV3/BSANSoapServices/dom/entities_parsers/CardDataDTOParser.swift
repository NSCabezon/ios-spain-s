import Foundation
import Fuzi

class CardDataDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> CardDataDTO {
        
        var cardDataDTO = CardDataDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "pan":
                    cardDataDTO.PAN = element.stringValue.trim()
                    break
                case "codigoPlastico":
                    cardDataDTO.visualCode = element.stringValue.trim()
                    break
                case "nombreEstampacion":
                    cardDataDTO.stampedName = element.stringValue.trim()
                    break
                case "limiteCredito":
                    cardDataDTO.creditLimitAmount = AmountDTOParser.parse(element)
                    break
                case "saldoDispuesto":
                    cardDataDTO.currentBalance = AmountDTOParser.parse(element)
                    break
                case "saldoDisponible":
                    cardDataDTO.availableAmount = AmountDTOParser.parse(element)
                    break
                default:
                    BSANLogger.e("CardDataDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return cardDataDTO
    }
}
