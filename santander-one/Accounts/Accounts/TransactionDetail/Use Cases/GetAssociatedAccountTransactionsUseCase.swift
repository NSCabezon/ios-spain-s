//
//  GetAssociatedAccountTransactionsUseCase.swift
//  Account
//
//  Created by Tania Castellano Brasero on 21/04/2020.

import CoreFoundationLib

public protocol GetAssociatedAccountTransactionsUseCase: UseCase<GetAssociatedAccountTransactionsUseCaseInput, GetAssociatedAccountTransactionsUseCaseOkOutput, StringErrorOutput> {}

class DefaultGetAssociatedAccountTransactionsUseCase: UseCase<GetAssociatedAccountTransactionsUseCaseInput, GetAssociatedAccountTransactionsUseCaseOkOutput, StringErrorOutput> {

    override func executeUseCase(requestValues: GetAssociatedAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetAssociatedAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetAssociatedAccountTransactionsUseCaseOkOutput(accountTransactions: []))
    }
}

extension DefaultGetAssociatedAccountTransactionsUseCase: GetAssociatedAccountTransactionsUseCase {}

public struct GetAssociatedAccountTransactionsUseCaseInput {
    public let accountTransaction: AccountTransactionEntity
}

public struct GetAssociatedAccountTransactionsUseCaseOkOutput {
    let accountTransactions: [AccountTransactionWithAccountEntity]
    
    public init(accountTransactions: [AccountTransactionWithAccountEntity]) {
        self.accountTransactions = accountTransactions
    }
}
