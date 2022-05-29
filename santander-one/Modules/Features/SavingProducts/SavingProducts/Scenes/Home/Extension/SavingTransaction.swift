//
//  SavingTransaction.swift
//  SavingProducts
//
//  Created by Jose Camallonga on 24/2/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class SavingTransaction {
    private let transaction: SavingTransactionRepresentable
    private let timeManager: TimeManager
    var isFirstRow: Bool = false
    var mustHideSeparationLine: Bool = false
    var mustShowBottomLineForSingleCell: Bool = false
    var mustShowPositiveAmount: Bool {
        return Decimal(string: transaction.amount.amount) ?? 0 > 0
    }
    
    init(transaction: SavingTransactionRepresentable, timeManager: TimeManager) {
        self.transaction = transaction
        self.timeManager = timeManager
    }
    
    var amountAttributeString: NSAttributedString? {
        return formatedAmount(transaction.amount)
    }
    
    var amountAccessibilityString: String? {
        guard let amountAttributeString = amountAttributeString?.string else { return nil }
        var characters = Array(amountAttributeString)
        if characters.first == "-", characters.element(atIndex: 1)?.isNumber == false {
            characters.swapAt(0, 1)
            return String(characters)
        } else {
            return amountAttributeString
        }
    }
    
    var date: Date {
        return transaction.bookingDateTime
    }
    
    var description: String {
        return transaction.supplementaryData?.shortDescription ?? ""
    }
    
    var detail: String {
        switch transaction.status {
        case "Pending":
            return timeManager.toString(date: transaction.bookingDateTime, outputFormat: .dd_MMM_yyyy) ?? ""
        default:
            return formatedAmount(transaction.balance?.amount)?.string ?? ""
        }
    }
    
    var isActive: Bool {
        return transaction.status != "Pending"
    }
}

private extension SavingTransaction {
    func formatedAmount(_ amount: SavingAmountRepresentable?) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        let font = UIFont.santander(family: .text, type: isActive ? .bold : .regular, size: 20)
        let currency = CurrencyType.parse(amount.currency)
        let amountEntity = AmountEntity(value: Decimal(string: amount.amount) ?? 0, currency: currency)
        let balance = MoneyDecorator(amountEntity, font: font, decimalFontSize: 16)
        return balance.getFormattedStringWithoutMillion()
    }
}
