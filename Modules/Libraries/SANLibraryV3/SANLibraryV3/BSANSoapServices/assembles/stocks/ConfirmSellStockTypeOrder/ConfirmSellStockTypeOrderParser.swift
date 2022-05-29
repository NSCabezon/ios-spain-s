import Foundation
import Fuzi

public class ConfirmSellStockTypeOrderParser : BSANParser <ConfirmSellStockTypeOrderResponse, ConfirmSellStockTypeOrderHandler> {
    override func setResponseData(){
        response.stockOperationDataConfirmDTO = handler.stockOperationDataConfirmDTO
    }
}

public class ConfirmSellStockTypeOrderHandler: BSANHandler {
    
    var stockOperationDataConfirmDTO = StockOperationDataConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockOperationDataConfirmDTO = StockOperationDataConfirmDTOParser.parse(result)
    }
}
