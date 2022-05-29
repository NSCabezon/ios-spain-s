import Foundation
import Fuzi

public class GetStockQuoteDetailParser : BSANParser <GetStockQuoteDetailResponse, GetStockQuoteDetailHandler> {
    override func setResponseData(){
        response.stockQuoteDetailDTO = handler.stockQuoteDetailDTO
    }
}

public class GetStockQuoteDetailHandler: BSANHandler {
    
    var stockQuoteDetailDTO = StockQuoteDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "datosBasicos":
            let stockQuoteDTO = StockQuoteDTOParser.parse(element)
            stockQuoteDetailDTO.ticker = stockQuoteDTO.ticker
            stockQuoteDetailDTO.name = stockQuoteDTO.name
            stockQuoteDetailDTO.marketPrice = stockQuoteDTO.marketPrice
            stockQuoteDetailDTO.identificationNumber = stockQuoteDTO.identificationNumber
            stockQuoteDetailDTO.stockCode = stockQuoteDTO.stockCode
        case "fechaCotizacion":
            stockQuoteDetailDTO.priceDate = DateFormats.safeDate(element.stringValue)
        case "horaCotizacion":
            stockQuoteDetailDTO.priceTime = DateFormats.safeTime(element.stringValue)
        case "cotizacionApertura":
            stockQuoteDetailDTO.openingPrice = AmountDTOParser.parse(element)
        case "cotizacionCierre":
            stockQuoteDetailDTO.closingPrice = AmountDTOParser.parse(element)
        case "valorMaximo":
            stockQuoteDetailDTO.dailyHigh = AmountDTOParser.parse(element)
        case "valorMinimo":
            stockQuoteDetailDTO.dailyLow = AmountDTOParser.parse(element)
        case "volumenNegociado":
            stockQuoteDetailDTO.volume = DTOParser.safeLong(element.stringValue.trim())
        default:
            BSANLogger.e("\(#function)", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
