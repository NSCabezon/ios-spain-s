//
//  AccountPendingTransactionGroupViewModel.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 23/11/21.
//
import CoreFoundationLib
import CoreDomain

class AccountPendingTransactionGroupViewModel: TransactionsGroupViewModel {
    var date: Date
    var transactions: [TransactionViewModel]
    var dateFormatted: LocalizedStylableText {
        LocalizedStylableText.empty
    }
    private let dependenciesResolver: DependenciesResolver
    private lazy var timeManager: TimeManager = {
        dependenciesResolver.resolve(for: TimeManager.self)
    }()
    
    init(transactions: [AccountPendingTransactionRepresentable], dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.date = Date.distantPast
        self.transactions = transactions.map({ AccountPendingTransactionViewModel(transaction: $0,
                                                                                  dependenciesResolver: dependenciesResolver) })
    }
    
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        return LocalizedStylableText.empty
    }
}
