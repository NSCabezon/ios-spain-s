//
//  SplitTransactionViewModel.swift
//  Bizum

import CoreFoundationLib
import UI

final class SplitTransactionViewModel {
    private(set) var title: TextWithAccessibility
    private(set) var amount: AmountEntity
    private(set) var origin: TextWithAccessibility?
    private(set) var amountWithAttributed: NSAttributedString?
    private(set) var amountAccessibility: String?

    public init(title: TextWithAccessibility,
                amount: AmountEntity,
                amountAccessibility: String,
                origin: TextWithAccessibility?) {
        self.title = title
        self.amount = amount
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        self.amountWithAttributed = moneyDecorator.getFormatedCurrency()
        self.amountAccessibility = amountAccessibility
        self.origin = origin
    }
}
