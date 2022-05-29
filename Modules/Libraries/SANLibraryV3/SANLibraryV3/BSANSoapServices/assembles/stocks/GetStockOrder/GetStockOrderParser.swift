import Foundation
import Fuzi

public class GetStockOrderParser : BSANParser <GetStockOrderResponse, GetStockOrderHandler> {
    override func setResponseData(){
        response.orderListDTO = handler.orderListDTO
        response.orderListDTO.pagination = handler.pagination
    }
}

public class GetStockOrderHandler: BSANHandler {
    
    var orderListDTO = OrderListDTO()
    var pagination: PaginationDTO?
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            orderListDTO = OrderListDTOParser.parse(lista)
        }
        
        pagination = PaginationParser.parse(result)
    }
}
