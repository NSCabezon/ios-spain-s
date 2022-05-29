import CoreDomain

public struct AccountTransactionsListDTO: Codable {
    public var transactionDTOs: [AccountTransactionDTO] = []
    public var pagination = PaginationDTO()
    
    public init() {}
    
    public init(transactionDTOs: [AccountTransactionDTO], pagination: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}
