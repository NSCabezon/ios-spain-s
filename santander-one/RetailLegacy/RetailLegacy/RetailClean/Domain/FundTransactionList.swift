import SANLegacyLibrary

struct FundTransactionsList {
    
    var transactions: [FundTransaction]?
    var pagination: PaginationDO?
    
    private var dto: FundTransactionDTO?
    
    init(_ dto: FundTransactionsListDTO) {
        self.transactions = dto.transactionDTOs.map { FundTransaction($0) }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
}
