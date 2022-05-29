//

import SANLegacyLibrary

struct ImpositionTransactionList: GenericTransactionProtocol {
    let impositionTransactions: [ImpositionTransaction]?
    let pagination: PaginationDO?
    
    init(_ dto: ImpositionTransactionsListDTO) {
        let imp = dto.transactionDTOs
        
        self.impositionTransactions = imp?.map { ImpositionTransaction(dto: $0) }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
}
