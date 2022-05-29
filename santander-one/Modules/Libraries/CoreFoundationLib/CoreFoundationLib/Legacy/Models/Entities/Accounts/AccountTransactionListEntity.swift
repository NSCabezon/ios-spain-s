//
//  AccountTransactionListEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import SANLegacyLibrary

public final class AccountTransactionListEntity {
    
    public let transactions: [AccountTransactionEntity]
    public let pagination: PaginationEntity
    
    public init(_ dto: AccountTransactionsListDTO) {
        transactions = dto.transactionDTOs.map(AccountTransactionEntity.init)
        pagination = PaginationEntity(dto.pagination)
    }

    public init(transactions: [AccountTransactionEntity], pagination: PaginationEntity = PaginationEntity()) {
        self.transactions = transactions
        self.pagination = pagination
    }
}

extension AccountTransactionListEntity {
   public func arePrior90Days() -> Bool {
        return self.transactions.contains { transaction in
            guard let operationDate = transaction.operationDate, let days = Calendar.current.dateComponents([.day], from: operationDate, to: Date()).day else { return false }
            return days >= 90
        }
    }
    
   public func getLast90Days() -> AccountTransactionListEntity {
        let transactionsFiltered = transactions.filter { transaction in
            guard let operationDate = transaction.operationDate, let days = Calendar.current.dateComponents([.day], from: operationDate, to: Date()).day else { return false }
            return days < 90
        }
        return AccountTransactionListEntity(transactions: transactionsFiltered)
    }
    
    public func getAfter90Days() -> AccountTransactionListEntity {
        let transactionsFiltered = transactions.filter { transaction in
            guard let operationDate = transaction.operationDate, let days = Calendar.current.dateComponents([.day], from: operationDate, to: Date()).day else { return false }
            return days >= 90
        }
        return AccountTransactionListEntity(transactions: transactionsFiltered, pagination: self.pagination)
    }
}
