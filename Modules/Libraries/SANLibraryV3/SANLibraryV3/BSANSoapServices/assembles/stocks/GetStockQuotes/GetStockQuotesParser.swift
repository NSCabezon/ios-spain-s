import Foundation
import Fuzi

public class GetStockQuotesParser : BSANParser <GetStockQuotesResponse, GetStockQuotesHandler> {
    override func setResponseData(){
        response.stockQuotesListDTO = handler.stockQuotesListDTO
    }
}

public class GetStockQuotesHandler: BSANHandler {
    
    var stockQuotesListDTO = StockQuotesListDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            stockQuotesListDTO = StockQuotesListDTOParser.parse(lista, pagination: PaginationParser.parse(result))
        }
    }
}
