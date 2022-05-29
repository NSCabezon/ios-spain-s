public struct LiquidationTransactionListDTO: Codable {
    public var liquidationDTOS: [LiquidationDTO]?
    public var pagination: PaginationDTO?

    public init() {}
    
    public init(liquidationDTOS: [LiquidationDTO]?, pagination: PaginationDTO?) {
        self.liquidationDTOS = liquidationDTOS
        self.pagination = pagination
    }
}
