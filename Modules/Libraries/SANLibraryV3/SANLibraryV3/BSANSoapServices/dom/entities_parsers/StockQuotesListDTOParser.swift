import Foundation
import Fuzi

class StockQuotesListDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement, pagination: PaginationDTO?) -> StockQuotesListDTO {
        var stockQuotesListDTO = StockQuotesListDTO()
        
        if node.children(tag: "datosCotizacion").count == 0{
            return stockQuotesListDTO
        }
        
        var stockQuoteDTOS: [StockQuoteDTO] = []
        
        for i in 0 ... node.children(tag: "datosCotizacion").count-1{
            let childElement = node.children(tag: "datosCotizacion")[i]
            let stockQuoteDTO = StockQuoteDTOParser.parse(childElement)
            stockQuoteDTOS.append(stockQuoteDTO)
        }
        stockQuotesListDTO.stockQuoteDTOS = stockQuoteDTOS
        if let pagination = pagination{
            stockQuotesListDTO.pagination = pagination
        }
        
        return stockQuotesListDTO
    }
}
