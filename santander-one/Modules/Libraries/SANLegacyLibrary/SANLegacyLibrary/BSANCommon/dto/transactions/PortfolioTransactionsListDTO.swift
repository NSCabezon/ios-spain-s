public struct PortfolioTransactionsListDTO: Codable {
    public var transactionDTOs: [PortfolioTransactionDTO]?
    public var pagination: PaginationDTO?

    public init() {}

    public init(transactionDTOs: [PortfolioTransactionDTO], pagination: PaginationDTO?) {
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}
