import CoreDomain

public struct FundTransactionsListDTO: Codable {
    public var transactionDTOs: [FundTransactionDTO] = []
    public var pagination = PaginationDTO()
    
    public init() {}
    
    public init(transactionDTOs: [FundTransactionDTO], pagination: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}

extension FundTransactionsListDTO: FundMovementListRepresentable {

    public var transactions: [FundMovementRepresentable] {
        return transactionDTOs
    }

    public var next: PaginationRepresentable? {
        return pagination.endList ? nil : pagination
    }
}
