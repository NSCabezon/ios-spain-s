import Foundation

public struct StockQuoteDetailDTO: Codable {
    public var marketPrice: AmountDTO?
    public var openingPrice: AmountDTO?
    public var closingPrice: AmountDTO?
    public var dailyHigh: AmountDTO?
    public var dailyLow: AmountDTO?
    public var priceDate: Date?
    public var priceTime: Date?
    
    // MARK: Basic
    public var ticker: String?
    public var stockCode: String?
    public var name: String?
    public var identificationNumber: String?
    public var volume: Int64?

    public init () {}
    
}
