//

import Foundation
import SANLegacyLibrary

struct CardTransactionsList {
    var transactions: [CardMovement]?
    var pagination: PaginationDO?
    
    init(_ dto: CardTransactionsListDTO) {
        self.transactions = dto.transactionDTOs.map { dto in
            let transaction = CardTransaction(dto)
            let movement = CardMovement(transaction: transaction)
            return movement
        }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
    
    init(_ dto: CardPendingTransactionsListDTO) {
        self.transactions = dto.cardPendingTransactionDTOS?.map { dto in
            let transaction = CardPendingTransaction(dto)
            let movement = CardMovement(transaction: transaction)
            return movement
        }
        self.pagination = PaginationDO(dto: dto.pagination)
    }
}
