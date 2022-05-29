//
//  BillEmittersPaymentSummaryBuilder.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 21/05/2020.
//

import Foundation
import Operative
import CoreFoundationLib

class BillEmittersPaymentSummaryBuilder {
    
    let operativeData: BillEmittersPaymentOperativeData
    let dependenciesResolver: DependenciesResolver
    var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    
    init(operativeData: BillEmittersPaymentOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAmount() {
        guard let amount = self.operativeData.amount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_amount"),
            subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue())
        )
        self.bodyItems.append(item)
    }
    
    func addOriginAccount() {
        guard let originAccount = self.operativeData.selectedAccount else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("summary_item_paymentAccount")
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: title.camelCased().text,
            subTitle: self.boldRegularAttributedString(bold: alias, regular: availableAmount)
        )
        self.bodyItems.append(item)
    }
    
    func addType() {
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_paymentType"),
            subTitle: localized("receiptsAndTaxes_label_receiptPayment")
        )
        self.bodyItems.append(item)
    }
    
    func addEmitter() {
        guard let emitterName = self.operativeData.selectedEmitter?.name else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_EntityIssuing"),
            subTitle: emitterName.capitalized
        )
        self.bodyItems.append(item)
    }
    
    func addEmitterCode() {
        guard let emitterCode = self.operativeData.selectedEmitter?.code else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_issuingEntity"),
            subTitle: emitterCode
        )
        self.bodyItems.append(item)
    }
    
    func addItems() {
        let items = self.operativeData.fields.map {
            OperativeSummaryStandardBodyItemViewModel(
                title: localized($0.key.fieldDescription.capitalized),
                subTitle: $0.value
            )
        }
        self.bodyItems.append(contentsOf: items)
    }
    
    func addDate() {
        guard let date = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: self.operativeData.formats?.systemDate, outputFormat: .d_MMM_yyyy) else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_collectionDate"),
            subTitle: date
        )
        self.bodyItems.append(item)
    }
    
    func addShare(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardBodyActionViewModel(
            image: "icnShare",
            title: localized("generic_button_share"),
            action: action
        )
        self.bodyActionItems.append(viewModel)
    }
    
    func addGoToBillsHome(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnPayment",
            title: localized("generic_button_anotherPayment"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoToOpinator(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1", title: localized("summe_title_perfect"), description: localized("summary_label_payOk"), extraInfo: localized("summary_label_periodPayReceipts")),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
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
