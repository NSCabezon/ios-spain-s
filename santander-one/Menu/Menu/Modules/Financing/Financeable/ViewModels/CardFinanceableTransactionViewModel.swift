//
//  CardFinanceableTransactionViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 29/06/2020.
//

import Foundation
import CoreFoundationLib

final class CardFinanceableTransactionViewModel {
    let transaction: CardTransactionEntity
    let cardEntity: CardEntity
    var baseUrl: String?
    
    init(_ transaction: CardTransactionEntity, cardEntity: CardEntity, baseUrl: String?) {
        self.transaction = transaction
        self.cardEntity = cardEntity
        self.baseUrl = baseUrl
    }
    
    var operativeDate: Date {
        return transaction.operationDate ?? Date()
    }
    
    var concept: String? {
        return transaction.description?.camelCasedString
    }
    
    var amount: NSAttributedString? {
        guard let amount = self.transaction.amount else { return nil }
        let font: UIFont = .santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 14)
        return decorator.formatAsMillions()
    }
    
    var dateFormatted: LocalizedStylableText {
        let decorator = DateDecorator(self.operativeDate)
        return decorator.setDateFormatter(false)
    }
    
    var cardDescription: String? {
        return self.cardEntity.getAliasAndInfo()
    }
    
    var miniatureImageUrl: String? {
        guard let baseUrl = baseUrl else { return nil }
        return baseUrl + self.cardEntity.buildImageRelativeUrl(miniature: true)
    }
}
