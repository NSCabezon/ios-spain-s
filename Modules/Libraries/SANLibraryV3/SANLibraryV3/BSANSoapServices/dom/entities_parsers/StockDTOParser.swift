import Foundation
import Fuzi

class StockDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockDTO {
        var stockDTO = StockDTO()
        stockDTO.stockQuoteDTO = StockQuoteDTOParser.parse(node)
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "posicionValor":
                    stockDTO.position = AmountDTOParser.parse(element)
                case "numTitulos":
                    stockDTO.sharesCount = DTOParser.safeInteger(element.stringValue.trim())
                default:
                    BSANLogger.e("ReferenceStandardDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return stockDTO
    }
}
