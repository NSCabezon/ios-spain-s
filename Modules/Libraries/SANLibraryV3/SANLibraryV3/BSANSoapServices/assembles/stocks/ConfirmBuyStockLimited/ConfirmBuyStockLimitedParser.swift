import Foundation
import Fuzi

public class ConfirmBuyStockLimitedParser : BSANParser <ConfirmBuyStockLimitedResponse, ConfirmBuyStockLimitedHandler> {
    override func setResponseData(){
        response.stockOperationDataConfirmDTO = handler.stockOperationDataConfirmDTO
    }
}

public class ConfirmBuyStockLimitedHandler: BSANHandler {
    
    var stockOperationDataConfirmDTO = StockOperationDataConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockOperationDataConfirmDTO = StockOperationDataConfirmDTOParser.parse(result)
    }
}
