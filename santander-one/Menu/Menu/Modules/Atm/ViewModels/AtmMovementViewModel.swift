//
//  FutureBillViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

class AtmMovementViewModel {
    let representable: AccountMovementRepresentable
    let account: AccountEntity
    
    init(_ representable: AccountMovementRepresentable, account: AccountEntity) {
        self.representable = representable
        self.account = account
    }
    
    var amount: NSAttributedString? {
        guard let amount = amountEntity else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.formatAsMillions()
    }
    
    var movementDescription: String {
        return self.representable.description.camelCasedString
    }
    
    var accountNumber: String {
        return String(format: "%@ | %@", account.alias ?? "", account.getIBANShort)
    }
    
    var date: Date {
        return representable.operationDate
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.representable.amountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}
