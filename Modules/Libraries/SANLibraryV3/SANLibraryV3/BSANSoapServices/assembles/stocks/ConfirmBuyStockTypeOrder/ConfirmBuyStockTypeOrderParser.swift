import Foundation
import Fuzi

public class ConfirmBuyStockTypeOrderParser : BSANParser <ConfirmBuyStockTypeOrderResponse, ConfirmBuyStockTypeOrderHandler> {
    override func setResponseData(){
        response.stockOperationDataConfirmDTO = handler.stockOperationDataConfirmDTO
    }
}

public class ConfirmBuyStockTypeOrderHandler: BSANHandler {
    
    var stockOperationDataConfirmDTO = StockOperationDataConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockOperationDataConfirmDTO = StockOperationDataConfirmDTOParser.parse(result)
    }
}
