//
//  SpainGetAssociatedAccountTransactionsUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 2/3/22.
//

import Foundation
import Account
import CoreFoundationLib

class SpainGetAssociatedAccountTransactionsUseCase: UseCase<GetAssociatedAccountTransactionsUseCaseInput, GetAssociatedAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let transactionsLimit = 10
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAssociatedAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetAssociatedAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        guard let userId = globalPosition.userCodeType else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let date = Date().getDateByAdding(days: -89, ignoreHours: true)
        let descriptionTag = requestValues.accountTransaction.type.rawValue
        guard !descriptionTag.isEmpty else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        var accountTransactions = globalPosition.accounts.visibles().reduce([AccountTransactionWithAccountEntity]()) { total, account in
            total + pfm.getMovementsFor(userId: userId, matches: descriptionTag, account: account, limit: transactionsLimit+1, date: date).map({ transaction in
                AccountTransactionWithAccountEntity(accountTransactionEntity: transaction, accountEntity: account)
            }).filter({ requestValues.accountTransaction.dgo != $0.accountTransactionEntity.dgo })
        }
        sort(accountTransactions: &accountTransactions)
        let accountTransactionsFiltered: [AccountTransactionWithAccountEntity] = Array(accountTransactions.prefix(transactionsLimit))
        return UseCaseResponse.ok(GetAssociatedAccountTransactionsUseCaseOkOutput(accountTransactions: accountTransactionsFiltered))
    }
}

extension SpainGetAssociatedAccountTransactionsUseCase: GetAssociatedAccountTransactionsUseCase {}

private extension SpainGetAssociatedAccountTransactionsUseCase {
    func sort(accountTransactions: inout [AccountTransactionWithAccountEntity]) {
        accountTransactions.sort {
            if SortingCriteria.datesAreDifferent(dateA: $0.accountTransactionEntity.operationDate, dateB: $1.accountTransactionEntity.operationDate) {
                return SortingCriteria.sortByDate(dateA: $0.accountTransactionEntity.operationDate, dateB: $1.accountTransactionEntity.operationDate, order: .orderedDescending)
            } else if SortingCriteria.ibanNumbersAreDifferent(firstAccount: $0.accountEntity, secondAccount: $1.accountEntity) {
                return SortingCriteria.sortByIBAN(firstAccount: $0.accountEntity, secondAccount: $1.accountEntity)
            } else {
                return SortingCriteria.sortByAmount(firstAmount: $0.accountTransactionEntity.amount?.value, secondAmount: $1.accountTransactionEntity.amount?.value)
            }
        }
    }
}
