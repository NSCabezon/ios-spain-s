//
//  BillEmittersPaymentConfirmationBuilder.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 21/05/2020.
//

import Foundation
import Operative
import CoreFoundationLib

class BillEmittersPaymentConfirmationBuilder {
    
    var items: [ConfirmationItemViewModel] = []
    let operativeData: BillEmittersPaymentOperativeData
    let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BillEmittersPaymentOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAmount(action: @escaping () -> Void) {
        guard let amount = self.operativeData.amount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amount"),
            value: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()),
            position: .first,
            action: ConfirmationItemAction(title: localized("generic_edit_link"), action: action),
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.ammount
        )
        self.items.append(item)
    }
    
    func addOriginAccount() {
        guard let originAccount = self.operativeData.selectedAccount else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        let title: LocalizedStylableText = localized("confirmation_item_paymentAccount")
        let item = ConfirmationItemViewModel(
            title: title,
            value: self.boldRegularAttributedString(bold: alias, regular: availableAmount),
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.originAccount
        )
        self.items.append(item)
    }
    
    func addType() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_paymentType"),
            value: localized("receiptsAndTaxes_label_receiptPayment"),
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.type
        )
        self.items.append(item)
    }
    
    func addEmitter() {
        let name = self.operativeData.selectedEmitter?.name ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_issuingEntity"),
            value: name.capitalized,
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.emitter
        )
        self.items.append(item)
    }
    
    func addEmitterCode() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_codeIssuingEntity"),
            value: self.operativeData.selectedEmitter?.code ?? "",
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.emitterCode
        )
        self.items.append(item)
    }
    
    func addItems() {
        let items = self.operativeData.fields.map {
            ConfirmationItemViewModel(
                title: localized($0.key.fieldDescription.capitalized),
                value: $0.value,
                accessibilityIdentifier: $0.key.fieldDescription.replace(" ", "_")
            )
        }
        self.items.append(contentsOf: items)
    }
    
    func addDate() {
        guard let date = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: self.operativeData.formats?.systemDate, outputFormat: .d_MMM_yyyy) else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_collectionDate"),
            value: date,
            position: .last,
            accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentConfirmationView.date
        )
        self.items.append(item)
    }
    
    func build() -> [ConfirmationItemViewModel] {
        return self.items
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
