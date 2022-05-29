public struct CardTransactionsListDTO: Codable {
    public var transactionDTOs: [CardTransactionDTO] = []
    public var pagination = PaginationDTO()

    public init() {}
    
    public init (transactionDTOs: [CardTransactionDTO], pagination: PaginationDTO){
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}
