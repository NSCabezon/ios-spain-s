//
//  AccountPendingTransactionViewModel.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 23/11/21.
//

import CoreFoundationLib
import CoreDomain

class AccountPendingTransactionViewModel {
    var transaction: AccountPendingTransactionRepresentable
    private let dependenciesResolver: DependenciesResolver
    private lazy var timeManager: TimeManager = {
        dependenciesResolver.resolve(for: TimeManager.self)
    }()
    
    init(transaction: AccountPendingTransactionRepresentable, dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.transaction = transaction
    }
}

extension AccountPendingTransactionViewModel: TransactionViewModel {
    var title: String? {
        transaction.description?.capitalized
    }
    
    var balanceString: String? {
        nil
    }
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = self.transaction.amountRepresentable else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = AmountRepresentableDecorator(amount, font: font, decimalFontSize: 16.0)
        return decorator.formattedCurrencyWithoutMillion
    }
    
    var amountValue: Decimal? {
        self.transaction.amountRepresentable?.value
    }
    
    var description: String? {
        nil
    }
    
    var isEasyPayEnabled: Bool {
        false
    }
    
    var formattedDate: String? {
        return timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)
    }
}
