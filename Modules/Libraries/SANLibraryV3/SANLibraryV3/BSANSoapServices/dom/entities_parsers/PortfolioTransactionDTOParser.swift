import Foundation
import Fuzi

class PortfolioTransactionDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PortfolioTransactionDTO {
        var portfolioTransactionDTO = PortfolioTransactionDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "numOperacion":
                    portfolioTransactionDTO.transactionNumber = element.stringValue.trim()
                case "tipoOperacion":
                    portfolioTransactionDTO.transactionType = element.stringValue.trim()
                case "fechaOperacion":
                    portfolioTransactionDTO.operationDate = DateFormats.safeDate(element.stringValue)
                case "numParticipaciones":
                    portfolioTransactionDTO.sharesCount = safeDecimal(element.stringValue.trim())
                case "impMovimiento":
                    portfolioTransactionDTO.amount = AmountDTOParser.parse(element)
                case "descMovimiento":
                    portfolioTransactionDTO.description = element.stringValue.trim()
                default:
                    BSANLogger.e("PortfolioProductPBDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return portfolioTransactionDTO
    }
}
