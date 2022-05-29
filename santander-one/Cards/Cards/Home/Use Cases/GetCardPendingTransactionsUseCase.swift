//
//  GetCardPendingTransactionsUseCase.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 7/28/20.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetCardPendingTransactionsUseCase: UseCase<GetCardPendingTransactionsUseCaseInput, GetCardPendingTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetCardPendingTransactionsUseCaseInput) throws -> UseCaseResponse<GetCardPendingTransactionsUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = provider.getBsanCardsManager()
        let cardDto = requestValues.card.dto
        let pagination = requestValues.pagination?.dto
        let response = try cardsManager.getCardPendingTransactions(cardDTO: cardDto, pagination: pagination)
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let result = CardPendingTransactionList(dto)
        let transactionList = CardTransactionsListEntity(
            transactions: result.transactions,
            pagination: result.pagination)
        return UseCaseResponse.ok(GetCardPendingTransactionsUseCaseOkOutput(transactionList: transactionList))
    }
}

struct GetCardPendingTransactionsUseCaseInput {
    let card: CardEntity
    let pagination: PaginationEntity?
}

struct GetCardPendingTransactionsUseCaseOkOutput {
    let transactionList: CardTransactionsListEntity
}
