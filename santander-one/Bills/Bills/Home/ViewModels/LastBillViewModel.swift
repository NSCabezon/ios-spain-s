//
//  LastBillViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import Foundation
import CoreFoundationLib

final class LastBillViewModel {
    let account: AccountEntity
    let bill: LastBillEntity
    private let localizedDate: LocalizedDate
    
    init(_ bill: LastBillEntity,
         account: AccountEntity,
         localizedDate: LocalizedDate) {
        self.bill = bill
        self.account = account
        self.localizedDate = localizedDate
    }
    
    var name: String {
        return self.bill.name.capitalized
    }
    
    var expirationDate: Date {
        return bill.expirationDate
    }
    
    var dateString: String {
        return localizedDate.dateString(expirationDate, format: .dd_MMM_yyyy)
    }
    
    var dateLocalized: LocalizedStylableText {
        return localizedDate.makeLocalizedDate(for: expirationDate)
    }
    
    var accountNumber: String {
        return String(format: "%@ | %@", account.alias ?? "", account.getIBANShort)
    }
    
    var amountAttributedText: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(self.bill.amountWithSymbol, font: font, decimalFontSize: 16)
        return amount.formatAsMillions()
    }
    
    var billStatus: (color: UIColor, text: LocalizedStylableText) {
        switch bill.status {
        case .canceled:
            return (.bostonRed, localized("generic_label_cancelled"))
        case .applied:
            return (.limeGreen, localized("generic_label_applied"))
        case .returned:
            return (.lisboaGray, localized("generic_label_Returned"))
        case .pendingToApply, .pendingOfDate, .pendingToResolve:
            return (.santanderYellow, localized("generic_label_pending"))
        default:
            return (.clear, .empty)
        }
    }
}
