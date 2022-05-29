//
//  GetFilteredAccountTransactionsUseCase.swift
//  Account
//
//  Created by Rodrigo Jurado on 25/8/21.
//

import CoreFoundationLib

public protocol GetFilteredAccountTransactionsUseCaseProtocol: UseCase<GetFilteredAccountTransactionsUseCaseInput, GetFilteredAccountTransactionsUseCaseOkOutput, StringErrorOutput> { }

public struct GetFilteredAccountTransactionsUseCaseInput {
    public let account: AccountEntity
    public let filters: TransactionFiltersEntity?
    public let pagination: PaginationEntity?
    
    public init(account: AccountEntity, filters: TransactionFiltersEntity?, pagination: PaginationEntity?) {
        self.account = account
        self.filters = filters
        self.pagination = pagination
    }
}

final class DefaultGetFilteredAccountTransactionsUseCase: UseCase<GetFilteredAccountTransactionsUseCaseInput, GetFilteredAccountTransactionsUseCaseOkOutput, StringErrorOutput>, GetFilteredAccountTransactionsUseCaseProtocol {
    
    override func executeUseCase(requestValues: GetFilteredAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetFilteredAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetFilteredAccountTransactionsUseCaseOkOutput(transactionList: AccountTransactionListEntity(transactions: [])))
    }
}

public struct GetFilteredAccountTransactionsUseCaseOkOutput {
    public let transactionList: AccountTransactionListEntity

    public init(transactionList: AccountTransactionListEntity) {
        self.transactionList = transactionList
    }
}
