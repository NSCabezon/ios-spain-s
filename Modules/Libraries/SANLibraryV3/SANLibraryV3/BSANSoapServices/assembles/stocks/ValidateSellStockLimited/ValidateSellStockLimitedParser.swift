import Foundation
import Fuzi

public class ValidateSellStockLimitedParser : BSANParser <ValidateSellStockLimitedResponse, ValidateSellStockLimitedHandler> {
    override func setResponseData(){
        response.stockDataSellDTO = handler.stockDataSellDTO
    }
}

public class ValidateSellStockLimitedHandler: BSANHandler {
    
    var stockDataSellDTO = StockDataBuySellDTO()
    
    override func parseResult(result: XMLElement) throws {
        stockDataSellDTO = StockDataBuySellDTOParser.parse(result)
    }
}
