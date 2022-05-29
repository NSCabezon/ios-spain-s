//
//  AccountFutureBillGroupViewModel.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/5/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

class AccountFutureBillGroupViewModel: TransactionsGroupViewModel {
    var date: Date
    var transactions: [TransactionViewModel]
    private let dependenciesResolver: DependenciesResolver
    
    init(date: Date, bills: [AccountFutureBillRepresentable],
         dependenciesResolver: DependenciesResolver) {
        self.date = date
        self.transactions = bills.map(AccountFutureBillViewModel.init)
        self.dependenciesResolver = dependenciesResolver
    }
    
    var dateFormatted: LocalizedStylableText {
        let dateString = dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date, outputFormat: .d_MMM)?.uppercased() ?? ""
        
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else if date.isTomorrow() {
            return localized("product_label_tomorrowTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return localized("product_label_nextTransaction", [StringPlaceholder(.date, dateString)])
        }
    }
    
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatter(filtered)
    }
}
