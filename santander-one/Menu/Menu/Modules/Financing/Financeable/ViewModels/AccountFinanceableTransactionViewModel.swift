//
//  AccountFinanceableTransactionViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class AccountFinanceableTransactionViewModel {
    let transaction: EasyPayTransactionFinanceable
    let accountEntity: AccountEntity
    var baseUrl: String?
    
    init(_ transaction: EasyPayTransactionFinanceable, accountEntity: AccountEntity) {
        self.transaction = transaction
        self.accountEntity = accountEntity
    }
    
    var movement: AccountMovementRepresentable {
        return self.transaction.movement
    }
    
    var operativeDate: Date {
        return self.movement.operationDate
    }
    
    var concept: String? {
        return self.movement.description.camelCasedString
    }
    
    var amount: NSAttributedString? {
        guard let amount = self.amountEntity else { return nil }
        let font: UIFont = .santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 14)
        return decorator.formatAsMillions()
    }
    
    var dateFormatted: LocalizedStylableText {
        let decorator = DateDecorator(self.operativeDate)
        return decorator.setDateFormatter(false)
    }
    
    var accountDescription: String? {
        guard let alias = self.accountEntity.alias else { return nil }
        let description = alias + " | " + self.getFormattedAccountNumber()
        return description
    }
    
    private func getFormattedAccountNumber() -> String {
        let number = self.accountEntity.getIBANFormatted
        return "*" + (number.substring(number.count - 4) ?? "*")
    }
    
    var offer: OfferEntityViewModel? {
        self.transaction.offer
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.movement.amountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}
