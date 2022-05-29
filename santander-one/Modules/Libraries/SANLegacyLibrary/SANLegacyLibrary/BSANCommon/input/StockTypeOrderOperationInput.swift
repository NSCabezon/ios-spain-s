import Foundation

public class StockTypeOrderOperationInput {
    public var stockTradingType: String
    public var tradesShare: String
    public var limitedDate: Date?
    
    public init(stockTradingType: String, tradesShare: String, limitedDate: Date?) {
        self.stockTradingType = stockTradingType
        self.tradesShare = tradesShare
        self.limitedDate = limitedDate
    }
}
