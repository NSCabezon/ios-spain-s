//
//  AccountTransactionViewModel.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import CoreFoundationLib

class AccountTransactionViewModel: TransactionViewModel {
    
    var transaction: AccountTransactionEntity
    let offers: [PullOfferLocation: OfferEntity]
    var easyPay: AccountEasyPay?
   
    init(transaction: AccountTransactionEntity, offers: [PullOfferLocation: OfferEntity], easyPay: AccountEasyPay?) {
        self.transaction = transaction
        self.offers = offers
        self.easyPay = easyPay
    }
    
    var title: String? {
        return transaction.alias?.capitalized
    }
    
    var balanceString: String? {
        guard let amount = self.transaction.balance else { return nil}
        return amount.getStringValueWithoutMillion()
    }
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = self.transaction.amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.formattedNotScaledWithoutMillion
    }
    
    var amountValue: Decimal? {
        self.transaction.amount?.value
    }
    
    var description: String? {
        return nil
    }
    
    var isEasyPayEnabled: Bool {
        switch easyPayFundableType {
        case .low where offers.contains(location: AccountsPullOffers.lowEasyPayAmountDetail): return true
        case .high where offers.contains(location: AccountsPullOffers.highEasyPayAmountDetail): return true
        default: return false
        }
    }
    
    var easyPayFundableType: AccountEasyPayFundableType {
        guard let amount = self.transaction.amount, let easyPay = self.easyPay else { return .notAllowed }
        return easyPayFundableType(for: amount, transaction: self.transaction, accountEasyPay: easyPay)
    }
}

extension AccountTransactionViewModel: AccountEasyPayChecker {}
extension AccountTransactionViewModel: Hashable {
    static func == (lhs: AccountTransactionViewModel, rhs: AccountTransactionViewModel) -> Bool {
        lhs.transaction.dgo == rhs.transaction.dgo
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transaction)
    }
}
