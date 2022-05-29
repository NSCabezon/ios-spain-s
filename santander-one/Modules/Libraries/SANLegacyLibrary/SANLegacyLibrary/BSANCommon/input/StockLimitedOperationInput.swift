import Foundation

public class StockLimitedOperationInput {
    public var maxExchange: AmountDTO
    public var tradesShare: String
    public var limitedDate: Date?
    
    public init(maxExchange: AmountDTO, tradesShare: String, limitedDate: Date?) {
        self.maxExchange = maxExchange
        self.tradesShare = tradesShare
        self.limitedDate = limitedDate
    }
}

