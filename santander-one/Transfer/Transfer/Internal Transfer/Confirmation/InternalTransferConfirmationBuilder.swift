//
//  InternalTransferConfirmationBuilder.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import Operative
import CoreFoundationLib

class InternalTransferConfirmationBuilder {
    
    var items: [ConfirmationItemViewModel] = []
    let internalTransfer: InternalTransferOperativeData
    let dependenciesResolver: DependenciesResolver
    
    required init(internalTransfer: InternalTransferOperativeData, dependenciesResolver: DependenciesResolver) {
        self.internalTransfer = internalTransfer
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAmount(action: ConfirmationItemAction?) {
        guard let amount = self.internalTransfer.amount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amount"),
            value: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()),
            action: action,
            accessibilityIdentifier: "confirmation_item_amount"
        )
        self.items.append(item)
    }
    
    func addConcept(action: ConfirmationItemAction?) {
        let concept: String = {
            guard let concept = self.internalTransfer.concept, !concept.isEmpty else { return localized("onePay_label_notConcept") }
            return concept
        }()
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_description"),
            value: concept,
            action: action,
            accessibilityIdentifier: "confirmation_item_description"
        )
        self.items.append(item)
    }
    
    func addOriginAccount(action: ConfirmationItemAction?) {
        guard let originAccount = self.internalTransfer.selectedAccount else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("confirmation_label_originAccount")
        var value: NSAttributedString = self.boldRegularAttributedString(bold: alias, regular: availableAmount)
        if action == nil {
            value = NSAttributedString(string: alias)
        }
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: value,
            action: action,
            accessibilityIdentifier: "confirmation_label_originAccount"
        )
        self.items.append(item)
    }
    
    func addTransferType() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_sendType"),
            value: localized("confirmation_text_transferNoCommissions"),
            accessibilityIdentifier: "confirmation_label_sendType"
        )
        self.items.append(item)
    }
    
    func addDate() {
        
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_date"),
            value: dateToString(date: self.internalTransfer.internalTransfer?.issueDate,
                                outputFormat: .dd_MMM_yyyy) ?? "",
            accessibilityIdentifier: "confirmation_item_date"
        )
        self.items.append(item)
    }
    
    func addDestinationAccount(action: ConfirmationItemAction?) {
        guard let originAccount = self.internalTransfer.destinationAccount else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var value: NSAttributedString = self.boldRegularAttributedString(bold: alias, regular: availableAmount)
        if action == nil {
            value = NSAttributedString(string: alias)
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_destination"),
            value: value,
            action: action,
            accessibilityIdentifier: "confirmation_label_destination"
        )
        self.items.append(item)
    }
    
    func build() -> [ConfirmationItemViewModel] {
        return self.items.enumerated().map {
            // If it is the last object, change the `position` attribute to `.last`
            if $0.offset == self.items.count - 1 {
                return ConfirmationItemViewModel(from: $0.element, position: .last)
            } else {
                return ConfirmationItemViewModel(from: $0.element, position: .unknown)
            }
        }
    }
    
    /// Returns a string with the following format: `bold (regular)`
    /// - Parameters:
    ///   - bold: The bold part of the string
    ///   - regular: The regular part of the string
    private func boldRegularAttributedString(bold: String, regular: String) -> NSAttributedString {
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
}
