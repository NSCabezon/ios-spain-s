//
//  CardListFinanceableTransactionViewModel.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import CoreFoundationLib
import Foundation

final class AccountListFinanceableTransactionViewModel {
    
    let account: AccountEntity
    let easyPayTransaction: EasyPayTransactionFinanceable
    
    init(account: AccountEntity, easyPayTransaction: EasyPayTransactionFinanceable) {
        self.account = account
        self.easyPayTransaction = easyPayTransaction
    }
    
    var operativeDate: Date {
        return self.easyPayTransaction.operationDate
    }
    
    var title: String? {
        return self.easyPayTransaction.movement.description.capitalized
    }
    
    var amount: NSAttributedString? {
        guard let amount = self.amountEntity else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.getFormatedCurrency()
    }
    
    var localizedDate: LocalizedStylableText {
        let decorator = DateDecorator(operativeDate)
        return decorator.setDateFormatter(false)
    }
    
    var offer: OfferEntity? {
        return self.easyPayTransaction.offer?.offer
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.easyPayTransaction.movement.amountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}

extension AccountListFinanceableTransactionViewModel: Equatable {
    static func == (lhs: AccountListFinanceableTransactionViewModel, rhs: AccountListFinanceableTransactionViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension AccountListFinanceableTransactionViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.easyPayTransaction.hashValue)
    }
}
