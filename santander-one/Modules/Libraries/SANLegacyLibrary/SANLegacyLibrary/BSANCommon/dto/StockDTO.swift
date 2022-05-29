public struct StockDTO: Codable {
    public var stockQuoteDTO = StockQuoteDTO()
    
    public var position: AmountDTO?
    public var sharesCount: Int?

    public init() {}
}
