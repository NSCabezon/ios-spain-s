import SANLegacyLibrary
import Foundation
import Fuzi

public class GetStockQuoteIBEXSANParser : BSANParser <GetStockQuoteIBEXSANResponse, GetStockQuoteIBEXSANHandler> {
    override func setResponseData(){
        response.stockQuotesListDTO = handler.stockQuotesListDTO
    }
}

public class GetStockQuoteIBEXSANHandler: BSANHandler {
    
    var stockQuotesListDTO = StockQuotesListDTO()
    
    override func parseResult(result: XMLElement) throws {

        stockQuotesListDTO.stockQuoteDTOS = [StockQuoteDTO]()

        var stockQuoteSAN = StockQuoteDTO()

        if let cotizacionSAN = result.firstChild(tag: "cotizacionSAN"){
            stockQuoteSAN.marketPrice = AmountDTOParser.parse(cotizacionSAN)
            stockQuoteSAN.ticker = Constants.TICKER_SAN
            stockQuoteSAN.name = Constants.NAME_SAN
        }
        
        if let cotizacionIBEX = result.firstChild(tag: "cotizacionIBEX"){
            var stockQuoteIBEX = StockQuoteDTO()
            stockQuoteIBEX.marketPrice = AmountDTOParser.parse(cotizacionIBEX)
            stockQuoteIBEX.ticker = Constants.TICKER_IBEX
            stockQuoteIBEX.name = Constants.NAME_IBEX
            
            stockQuotesListDTO.stockQuoteDTOS?.append(stockQuoteIBEX)
        }
        
        if let codigoEmisionSAN = result.firstChild(tag: "codigoEmisionSAN"){
            if let CODIGO_DE_VALOR = codigoEmisionSAN.firstChild(tag: "CODIGO_DE_VALOR"){
                stockQuoteSAN.stockCode = CODIGO_DE_VALOR.stringValue.trim()
            }
            if let CODIGO_DE_EMISION = codigoEmisionSAN.firstChild(tag: "CODIGO_DE_EMISION"){
                stockQuoteSAN.identificationNumber = CODIGO_DE_EMISION.stringValue.trim()
            }
        }
        
        stockQuotesListDTO.stockQuoteDTOS?.append(stockQuoteSAN)
    }
}
