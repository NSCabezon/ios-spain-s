//
//  GetFilteredCardTransactionsUseCaseProtocol.swift
//  Cards
//
//  Created by Julio Nieto Santiago on 9/2/22.
//

import CoreFoundationLib

public protocol GetFilteredCardTransactionsUseCaseProtocol: UseCase<GetFilteredCardTransactionsUseCaseInput, GetFilteredCardTransactionsUseCaseOkOutput, StringErrorOutput> { }

public struct GetFilteredCardTransactionsUseCaseInput {
    public let card: CardEntity
    public let filters: TransactionFiltersEntity?
    public let pagination: PaginationEntity?
    
    public init(card: CardEntity, filters: TransactionFiltersEntity?, pagination: PaginationEntity?) {
        self.card = card
        self.filters = filters
        self.pagination = pagination
    }
}

public struct GetFilteredCardTransactionsUseCaseOkOutput {
    public let transactionList: CardTransactionsListEntity

    public init(transactionList: CardTransactionsListEntity) {
        self.transactionList = transactionList
    }
}
