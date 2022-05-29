//
//  BizumRefundMoneyConfirmationBuilder.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 10/12/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import UI
import SANLibraryV3

final class BizumRefundMoneyConfirmationBuilder {
    private let data: BizumRefundMoneyOperativeData
    private var items: [BizumConfirmationViewModel] = []
    let dependenciesResolver: DependenciesResolver
    
    init(data: BizumRefundMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.data = data
        self.dependenciesResolver = dependenciesResolver
    }
    
    func build() -> [BizumConfirmationViewModel] {
        return self.items
    }
    
    func addAmountAndConcept() {
        guard let moneyDecorator = MoneyDecorator(self.data.totalAmount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18).getFormatedAbsWith1M() else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amountReceived"),
        value: moneyDecorator,
            position: .first,
            info: NSAttributedString(string: getOperationConcept()),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationAmount.rawValue
        )
        self.items.append(.confirmation(item: item))
    }

    func addOriginAccount() {
        let alias = self.data.account?.alias ?? ""
        let availableAmount = self.data.account?.availableAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("confirmation_text_origin")
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: self.boldRegularAttributedString(bold: alias, regular: availableAmount),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationOrigin.rawValue
        )
        self.items.append(.confirmation(item: item))
    }
    
    func addTransferType() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_sendType"),
            value: localized("confirmation_text_bizumNoCommissions"),
            position: .last,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationSendType.rawValue)
        self.items.append(.confirmation(item: item))
    }
    
    func addDate() {
        guard let date = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: self.data.operation.date, outputFormat: .d_MMM_yyyy) else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_shippingDate"),
            value: date,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationShippingDate.rawValue
        )
        self.items.append(.date(item: item))
    }
    
    func addContacts() {
        let item = ConfirmationContainerViewModel(title: localized("confirmation_item_receivedFrom"), views: [])
        self.items.append(.contacts(item: item))
    }
    
    func addTotal() {
        let item = ConfirmationTotalOperationItemViewModel(amountEntity: self.data.totalAmount)
        self.items.append(.total(time: item))
    }
}

private extension BizumRefundMoneyConfirmationBuilder {
    /// Returns a string with the following format: `bold (regular)`
    /// - Parameters:
    ///   - bold: The bold part of the string
    ///   - regular: The regular part of the string
    func boldRegularAttributedString(bold: String, regular: String) -> NSAttributedString {
        let regularWithParenthesis = "(" + regular + ")"
        let builder = TextStylizer.Builder(fullText: bold + " " + regularWithParenthesis)
        let boldStyle = TextStylizer.Builder.TextStyle(word: bold)
        let regularStyle = TextStylizer.Builder.TextStyle(word: regularWithParenthesis)
        return builder.addPartStyle(part: boldStyle
            .setColor(.lisboaGray)
            .setStyle(.santander(family: .text, type: .bold, size: 14))
        ).addPartStyle(part: regularStyle
            .setColor(.lisboaGray)
            .setStyle(.santander(family: .text, size: 14))
        ).build()
    }
    
    func getOperationConcept() -> String {
        guard let concept = self.data.operation.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
       }
       return concept
    }
}
