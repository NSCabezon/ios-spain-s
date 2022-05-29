//
//  AccountTransactionsGroupViewModel.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import CoreFoundationLib

class AccountTransactionsGroupViewModel: TransactionsGroupViewModel {
    var date: Date
    var transactions: [TransactionViewModel]
    private let dependenciesResolver: DependenciesResolver
    
    init(date: Date, transactions: [AccountTransactionEntity],
         offers: [PullOfferLocation: OfferEntity],
         dependenciesResolver: DependenciesResolver, easyPay: AccountEasyPay?) {
        self.date = date
        self.transactions = transactions.map({ AccountTransactionViewModel(transaction: $0, offers: offers, easyPay: easyPay) })
        self.dependenciesResolver = dependenciesResolver
    }
    
    var dateFormatted: LocalizedStylableText {
        let dateString =  dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date, outputFormat: .d_MMM)?.uppercased() ?? ""
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else if date.isTomorrow() {
            return localized("product_label_tomorrowTransaction", [StringPlaceholder(.date, dateString)])
        } else if date.isAfterTomorrow() {
            return localized("product_label_nextTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
    
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatterComplete(filtered)
    }
}
