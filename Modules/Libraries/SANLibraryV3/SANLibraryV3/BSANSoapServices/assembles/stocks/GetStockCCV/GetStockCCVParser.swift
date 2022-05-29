import Foundation
import Fuzi

public class GetStockCCVParser : BSANParser <GetStockCCVResponse, GetStockCCVHandler> {
    override func setResponseData(){
        response.stockListDTO = handler.stockListDTO
        response.stockListDTO.pagination = handler.pagination
        response.stockListDTO.positionAmount = handler.posicionAmount
    }
}

public class GetStockCCVHandler: BSANHandler {
    
    var stockListDTO = StockListDTO()
    var pagination = PaginationDTO()
    var posicionAmount : AmountDTO?
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            stockListDTO = StockListDTOParser.parse(lista)
        }
        
        if let posicionContratoValores = result.firstChild(tag: "posicionContratoValores"){
            posicionAmount = AmountDTOParser.parse(posicionContratoValores)
        }
        
        pagination = PaginationParser.parse(result)
    }
}
