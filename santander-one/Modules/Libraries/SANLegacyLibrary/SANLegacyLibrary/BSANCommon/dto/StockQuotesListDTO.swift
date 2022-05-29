public struct StockQuotesListDTO: Codable {
    public var stockQuoteDTOS: [StockQuoteDTO]?
    public var pagination: PaginationDTO?

    public init () {}
}
