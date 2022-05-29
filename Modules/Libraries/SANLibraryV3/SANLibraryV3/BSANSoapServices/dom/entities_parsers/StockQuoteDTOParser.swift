import Foundation
import Fuzi

class StockQuoteDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockQuoteDTO {
        var stockQuoteDTO = StockQuoteDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "codigoEmisionValores":
                    if let CODIGO_DE_VALOR = element.firstChild(tag: "CODIGO_DE_VALOR"){
                        stockQuoteDTO.stockCode = CODIGO_DE_VALOR.stringValue.trim()
                    }
                    if let CODIGO_DE_EMISION = element.firstChild(tag: "CODIGO_DE_EMISION"){
                        stockQuoteDTO.identificationNumber = CODIGO_DE_EMISION.stringValue.trim()
                    }
                case "tickerValor":
                    stockQuoteDTO.ticker = element.stringValue.trim()
                case "nombreValor":
                    stockQuoteDTO.name = element.stringValue.trim()
                case "fechaCotizacion":
                    stockQuoteDTO.priceDate = DateFormats.safeDate(element.stringValue)
                case "horaCotizacion":
                    stockQuoteDTO.priceTime = DateFormats.safeTime(element.stringValue)
                case "cotizacionValor":
                    stockQuoteDTO.marketPrice = AmountDTOParser.parse(element)
                default:
                    BSANLogger.e("FileTypeDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return stockQuoteDTO
    }
}
