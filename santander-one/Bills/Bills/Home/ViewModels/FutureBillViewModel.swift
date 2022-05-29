//
//  FutureBillViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

class FutureBillViewModel {
    let representable: AccountFutureBillRepresentable
    let account: AccountEntity
    let localizedDate: LocalizedDate
    
    init(_ representable: AccountFutureBillRepresentable, account: AccountEntity, localizedDate: LocalizedDate) {
        self.representable = representable
        self.account = account
        self.localizedDate = localizedDate
    }
    
    var personName: String? {
        return representable.personName?.capitalized
    }
    
    var amount: NSAttributedString? {
        guard let amount = amountEntity else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 14)
        return decorator.formatAsMillions()
    }
    
    var accountNumber: String {
        return String(format: "%@ | %@", account.alias ?? "", account.getIBANShort)
    }
    
    var date: Date {
        return representable.billDateExpiryDate ?? Date()
    }
    
    var dateLocalized: LocalizedStylableText {
        self.localizedDate.makeComingLocalizedDate(for: representable.billDateExpiryDate)
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.representable.billAmountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}
