public struct StockListDTO: Codable {
    public var stockListDTO: [StockDTO]?
    public var pagination: PaginationDTO?
    public var positionAmount: AmountDTO?
    
    public init () {}

    public init (stockListDTO: [StockDTO]?, pagination: PaginationDTO?, positionAmount: AmountDTO?) {
        self.stockListDTO = stockListDTO
        self.pagination = pagination
        self.positionAmount = positionAmount
    }
}
