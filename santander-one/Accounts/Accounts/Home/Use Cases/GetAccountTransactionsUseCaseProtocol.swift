//
//  GetAccountTransactionsUseCaseProtocol.swift
//  Account
//
//  Created by Rodrigo Jurado on 10/9/21.
//

import CoreFoundationLib
import CoreDomain

public protocol GetAccountTransactionsUseCaseProtocol: UseCase<GetAccountTransactionsUseCaseInput, GetAccountTransactionsUseCaseOkOutput, StringErrorOutput> { }

public struct GetAccountTransactionsUseCaseInput {
    public let account: AccountEntity
    public let pagination: PaginationEntity?
    public let scaState: ScaState?
    public let filters: TransactionFiltersEntity?
    public let filtersIsShown: Bool?
}

public struct GetAccountTransactionsUseCaseOkOutput {
    public let transactionsType: GetAccountTransactionsState
    public let futureBillList: AccountFutureBillListRepresentable?

    public init(transactionsType: GetAccountTransactionsState, futureBillList: AccountFutureBillListRepresentable?) {
        self.transactionsType = transactionsType
        self.futureBillList = futureBillList
        }
}

public enum GetAccountTransactionsState {
    case transactionsAfter90Days(AccountTransactionListEntity)
    case transactionsPrior90Days(before: AccountTransactionListEntity, after: AccountTransactionListEntity?)
    case noTransactions
}

public protocol AccountTransactionsModifierProtocol {
    func getTransactionsState(for transactionEntity: AccountTransactionListEntity, filtersIsShown: Bool) -> GetAccountTransactionsState
    func getActiveFilter(for transactions: [Date: [AccountTransactionEntity]]) -> TransactionFiltersEntity?
}
