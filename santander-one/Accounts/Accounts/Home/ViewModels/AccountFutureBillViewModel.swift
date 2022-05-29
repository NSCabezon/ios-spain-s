//
//  AccountFuruteBillViewModel.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/5/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

class AccountFutureBillViewModel: TransactionViewModel {
    
    let billRepresentable: AccountFutureBillRepresentable
    
    init(_ billRepresentable: AccountFutureBillRepresentable) {
        self.billRepresentable = billRepresentable
    }
    
    var title: String? {
        return self.billRepresentable.personName?.capitalized
    }
    
    var balanceString: String? {
        return nil
    }
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = self.amountEntity else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font)
        return decorator.formatAsMillions()
    }
    
    var amountValue: Decimal? {
        return self.amountEntity?.value
    }
    
    var description: String? {
        return self.billRepresentable.billConcept
    }
    
    var isEasyPayEnabled: Bool {
        return false
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.billRepresentable.billAmountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}
