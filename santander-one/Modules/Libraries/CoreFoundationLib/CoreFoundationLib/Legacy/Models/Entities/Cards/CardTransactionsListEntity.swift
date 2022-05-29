import Foundation
import SANLegacyLibrary

public struct CardTransactionsListEntity {
    public var transactions: [CardTransactionEntityProtocol]
    public var pagination: PaginationEntity?
    
    public init(transactions: [CardTransactionEntityProtocol], pagination: PaginationEntity? = nil) {
        self.transactions = transactions
        self.pagination = pagination
    }
    
    public init(_ dto: CardTransactionsListDTO) {
        transactions = dto.transactionDTOs.map(CardTransactionEntity.init)
        pagination = PaginationEntity(dto.pagination)
    }
}
