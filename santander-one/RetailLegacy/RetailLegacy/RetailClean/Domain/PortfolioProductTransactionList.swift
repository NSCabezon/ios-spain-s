//

import SANLegacyLibrary

struct PortfolioProductTransactionList {
    var transactions: [PortfolioProductTransaction]?
    var pagination: PaginationDO?

    init(_ dto: PortfolioTransactionsListDTO) {
        self.transactions = dto.transactionDTOs?.map { PortfolioProductTransaction(dto: $0) }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
}
