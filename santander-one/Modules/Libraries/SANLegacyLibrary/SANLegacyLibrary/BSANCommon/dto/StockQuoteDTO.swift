import Foundation

public struct StockQuoteDTO: Codable {
    public var marketPrice: AmountDTO?
    public var priceDate: Date?
    public var priceTime: Date?
    
    // MARK: Basic
    public var ticker: String?
    public var stockCode: String?
    public var name: String?
    public var identificationNumber: String?
    
    public init() {}

    public func getLocalId() -> String?{
        if let stockCode = stockCode, let identificationNumber = identificationNumber{
            return stockCode + identificationNumber
        }
        
        return nil
    }
    
    public func toString() -> String {
        return "\(ticker ?? "") \(name ?? "") (\(identificationNumber ?? ""))"
    }
}
