public struct LoanTransactionsListDTO: Codable {
    public var transactionDTOs: [LoanTransactionDTO] = []
    public var pagination = PaginationDTO()
    
    public init() {}

    public init(transactionDTOs: [LoanTransactionDTO], pagination: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}
