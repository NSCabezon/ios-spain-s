//
//  BizumAcceptRequestMoneyConfirmationBuilder.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 03/12/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import UI
import SANLibraryV3

enum BizumConfirmationViewModel {
    case confirmation(item: ConfirmationItemViewModel)
    case contacts(item: ConfirmationContainerViewModel)
    case total(time: ConfirmationTotalOperationItemViewModel)
    case date(item: ConfirmationItemViewModel)
}

final class BizumAcceptRequestMoneyConfirmationBuilder {
    private let data: BizumAcceptMoneyRequestOperativeData
    private var items: [BizumConfirmationViewModel] = []
    let dependenciesResolver: DependenciesResolver
    
    init(data: BizumAcceptMoneyRequestOperativeData, dependenciesResolver: DependenciesResolver) {
        self.data = data
        self.dependenciesResolver = dependenciesResolver
    }
    
    func build() -> [BizumConfirmationViewModel] {
        return self.items
    }
    
    func addAmountAndConcept() {
        guard let amount = self.data.bizumSendMoney?.amount,
            let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18).getFormatedAbsWith1M() else { return }
        let concept: String = data.bizumSendMoney?.concept ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_amountRequested"),
        value: moneyDecorator,
            position: .first,
            info: NSAttributedString(string: concept),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationAmount.rawValue
        )
        self.items.append(.confirmation(item: item))
    }

    func addOriginAccount() {
        let alias = self.data.accountEntity?.alias ?? ""
        let availableAmount = self.data.accountEntity?.availableAmount?.getStringValue() ?? ""
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
        guard let date = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: self.data.operation?.date, outputFormat: .d_MMM_yyyy) else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_applicationDate"),
            value: date,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationShippingDate.rawValue
        )
        self.items.append(.date(item: item))
    }
    
    func addContacts() {
        let item = ConfirmationContainerViewModel(title: localized("confirmation_item_sender"), views: [])
        self.items.append(.contacts(item: item))
    }
    
    func addTotal() {
        guard let amount = self.data.bizumSendMoney?.amount else { return }
        let item = ConfirmationTotalOperationItemViewModel(amountEntity: amount)
        self.items.append(.total(time: item))
    }
}

private extension BizumAcceptRequestMoneyConfirmationBuilder {
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
}
