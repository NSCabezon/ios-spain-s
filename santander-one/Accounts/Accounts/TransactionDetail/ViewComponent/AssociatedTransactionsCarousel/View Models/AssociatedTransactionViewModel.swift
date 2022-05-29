//
//  AssociatedTransactionViewModel.swift
//  Account
//
//  Created by Tania Castellano Brasero on 23/04/2020.
//

import Foundation
import CoreFoundationLib

struct AssociatedTransactionViewModel {
    let entity: AccountTransactionWithAccountEntity
    private let dependenciesResolver: DependenciesResolver
    
    init(_ transactionEntity: AccountTransactionWithAccountEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = transactionEntity
        self.dependenciesResolver = dependenciesResolver
    }
    
    var title: LocalizedStylableText {
        return localized(entity.accountTransactionEntity.alias?.camelCasedString ?? "")
    }
    var description: LocalizedStylableText {
        return localized(entity.accountEntity.alias?.camelCasedString ?? "")
    }
    
    var dateDescription: LocalizedStylableText {
        let dateString = dependenciesResolver.resolve(for: TimeManager.self).toStringFromCurrentLocale(date: entity.accountTransactionEntity.operationDate, outputFormat: .dd_MMM_yyyy) ?? ""
        return localized("relatedTransaction_label_operationDate", [StringPlaceholder(.date, dateString)])
    }
    
    var amountAttributed: NSAttributedString? {
        return self.amountAttributedString
    }
    
    var amountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = entity.accountTransactionEntity.amount else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 18)
        return amount.getFormatedCurrency()
    }
}
