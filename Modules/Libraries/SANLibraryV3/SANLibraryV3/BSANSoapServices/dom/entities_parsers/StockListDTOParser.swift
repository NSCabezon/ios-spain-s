import Foundation
import Fuzi

class StockListDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockListDTO {
        var stockListDTO = StockListDTO()
        
        if node.children(tag: "cartera").count == 0{
            return stockListDTO
        }
        
        var list: [StockDTO] = []
        
        for i in 0 ... node.children(tag: "cartera").count-1{
            let childElement = node.children(tag: "cartera")[i]
            let stockDTO = StockDTOParser.parse(childElement)
            list.append(stockDTO)
        }
        stockListDTO.stockListDTO = list
        return stockListDTO
    }
}
