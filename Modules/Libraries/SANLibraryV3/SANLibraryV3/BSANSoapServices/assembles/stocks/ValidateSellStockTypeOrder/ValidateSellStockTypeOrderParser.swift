import Foundation
import Fuzi

public class ValidateSellStockTypeOrderParser : BSANParser <ValidateSellStockTypeOrderResponse, ValidateSellStockTypeOrderHandler> {
    override func setResponseData(){
        response.stockDataSellDTO = handler.stockDataSellDTO
    }
}

public class ValidateSellStockTypeOrderHandler: BSANHandler {
    
    var stockDataSellDTO = StockDataBuySellDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockDataSellDTO = StockDataBuySellDTOParser.parse(result)
    }
}
