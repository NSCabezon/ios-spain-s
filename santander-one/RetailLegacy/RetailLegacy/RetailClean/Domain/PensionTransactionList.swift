import SANLegacyLibrary

struct PensionTransactionsList {
    
    var transactions: [PensionTransaction]?
    var pagination: PaginationDO?
    
    private var dto: PensionTransactionDTO?
    
    init(_ dto: PensionTransactionsListDTO) {
        self.transactions = dto.transactionDTOs.map { PensionTransaction($0) }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
}
