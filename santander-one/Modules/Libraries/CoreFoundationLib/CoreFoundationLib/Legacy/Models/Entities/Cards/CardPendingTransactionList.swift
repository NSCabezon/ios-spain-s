//
//  CardPendingTransactionList.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 7/28/20.
//

import Foundation
import SANLegacyLibrary

public final class CardPendingTransactionList {
    let dto: CardPendingTransactionsListDTO
    
    public init(_ dto: CardPendingTransactionsListDTO) {
        self.dto = dto
    }
    
    public var transactions: [CardPendingTransactionEntity] {
        return dto.cardPendingTransactionDTOS?
            .map(CardPendingTransactionEntity.init) ?? []
    }
    
    public var pagination: PaginationEntity? {
        guard let pagination = dto.pagination else { return nil }
        return PaginationEntity(pagination)
    }
}
