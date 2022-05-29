import Foundation
import Fuzi

public class ConfirmSellStockLimitedParser : BSANParser <ConfirmSellStockLimitedResponse, ConfirmSellStockLimitedHandler> {
    override func setResponseData(){
        response.stockOperationDataConfirmDTO = handler.stockOperationDataConfirmDTO
    }
}

public class ConfirmSellStockLimitedHandler: BSANHandler {
    
    var stockOperationDataConfirmDTO = StockOperationDataConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockOperationDataConfirmDTO = StockOperationDataConfirmDTOParser.parse(result)
    }
}
