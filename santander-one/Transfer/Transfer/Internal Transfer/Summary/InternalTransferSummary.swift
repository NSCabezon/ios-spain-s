//
//  InternalTransferSummary.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 14/01/2020.
//

import Foundation
import Operative
import CoreFoundationLib
import UI

public class InternalTransferSummaryContentBuilder {

    let operativeData: InternalTransferOperativeData
    var items: [OperativeSummaryStandardBodyItemViewModel] = []
    let dependenciesResolver: DependenciesResolver

    init(operativeData: InternalTransferOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func addAmountAndConcept() {
        guard let amount = self.operativeData.amount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let concept: String = {
            guard let concept = self.operativeData.concept, !concept.isEmpty else { return localized("onePay_label_notConcept") }
            return concept
        }()
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_amount"),
            subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()),
            info: concept,
            accessibilityIdentifier: "confirmation_item_amount_and_description"
        )
        self.items.append(item)
    }
    
    public func addAmount() {
        guard let amount = self.operativeData.amount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_amount"),
            subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()),
            accessibilityIdentifier: "confirmation_item_amount"
        )
        self.items.append(item)
    }
    
    public func addConcept() {
        let concept: String = {
            guard let concept = self.operativeData.concept, !concept.isEmpty else { return localized("onePay_label_notConcept") }
            return concept
        }()
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_description"),
            subTitle: concept,
            accessibilityIdentifier: "summary_item_description"
        )
        self.items.append(item)
    }
    
    public func addOriginAccount() {
        guard let originAccount = self.operativeData.selectedAccount else { return }
        let alias = originAccount.alias ?? ""
        var title: LocalizedStylableText = localized("summary_item_originAccount")
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: title.camelCased().text,
            subTitle: NSAttributedString(string: alias),
            accessibilityIdentifier: "summary_item_originAccount"
        )
        self.items.append(item)
    }
    
    public func addDestinationAccount() {
        guard let originAccount = self.operativeData.destinationAccount else { return }
        let alias = originAccount.alias ?? ""
        var title: LocalizedStylableText = localized("summary_label_destination")
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: title.camelCased().text,
            subTitle: NSAttributedString(string: alias),
            accessibilityIdentifier: "summary_label_destination"
        )
        self.items.append(item)
    }
    
    public func addTransferType() {
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_sendType"),
            subTitle: NSAttributedString(string: localized("summary_text_transferNoCommissions")),
            accessibilityIdentifier: "summary_item_sendType"
        )
        self.items.append(item)
    }
    
    func addMailExpenses() {
        guard let internalTransfer = self.operativeData.internalTransfer else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_mailExpenses"),
            subTitle: NSAttributedString(string: internalTransfer.expensesAmount.getFormattedAmountAsMillions()),
            accessibilityIdentifier: "summary_item_mailExpenses"
        )
        self.items.append(item)
    }
    
    func addTotalAmount() {
        guard let internalTransfer = self.operativeData.internalTransfer else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_amountToDebt"),
            subTitle: NSAttributedString(string: internalTransfer.netAmount.getFormattedAmountAsMillions()),
            accessibilityIdentifier: "summary_item_amountToDebt"
        )
        self.items.append(item)
    }
    
    public func addDate() {
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_transactionDate"),
            subTitle: dateToString(date: self.operativeData.internalTransfer?.issueDate, outputFormat: .dd_MMM_yyyy) ?? "",
            accessibilityIdentifier: "summary_item_transactionDate"
        )
        self.items.append(item)
    }
    
    public func build() -> [OperativeSummaryStandardBodyItemViewModel] {
        return self.items
    }
}

final class InternalTransferSummaryFooterBuilder {
    
    let operativeData: InternalTransferOperativeData
    var items: [OperativeSummaryStandardFooterItemViewModel] = []

    init(operativeData: InternalTransferOperativeData) {
        self.operativeData = operativeData
    }
    
    func addGoToSendMoney(action: @escaping () -> Void) {
        let item = OperativeSummaryStandardFooterItemViewModel(imageKey: "icnEnviarDinero",
                                                               title: localized("generic_button_anotherSendMoney"),
                                                               accessibilityIdentifier: "generic_button_anotherSendMoney",
                                                               action: action)
        self.items.append(item)
    }
    
    func addGoToGlobalPosition(action: @escaping () -> Void) {
        let item = OperativeSummaryStandardFooterItemViewModel(imageKey: "icnHome",
                                                               title: localized("generic_button_globalPosition"),
                                                               accessibilityIdentifier: "generic_button_globalPosition",
                                                               action: action)
        self.items.append(item)
    }
    
    func addGoToOpinator(action: @escaping () -> Void) {
        let item = OperativeSummaryStandardFooterItemViewModel(imageKey: "icnLike",
                                                               title: localized("generic_button_improve"),
                                                               accessibilityIdentifier: "generic_button_improve",
                                                               action: action)
        self.items.append(item)
    }
    
    func build() -> [OperativeSummaryStandardFooterItemViewModel] {
        return self.items
    }
}

final class InternalTransferSummaryActionsBuilder {
    
    let operativeData: InternalTransferOperativeData
    var items: [OperativeSummaryStandardBodyActionViewModel] = []

    init(operativeData: InternalTransferOperativeData) {
        self.operativeData = operativeData
    }
        
    func addDownloadPdf(action: @escaping () -> Void) {
        let item = OperativeSummaryStandardBodyActionViewModel(image: "icnRedPdf",
                                                               title: localized("cardsOption_button_dowloadPDF"),
                                                               titleAccessibilityIdentifier: "cardsOption_button_dowloadPDF",
                                                               action: action)
        self.items.append(item)
    }
    
    func addShare(action: @escaping () -> Void) {
        let item = OperativeSummaryStandardBodyActionViewModel(image: "icnShare",
                                                               title: localized("cardsOption_button_share"),
                                                               titleAccessibilityIdentifier: "cardsOption_button_share",
                                                               action: action)
        self.items.append(item)
    }
    
    func build() -> [OperativeSummaryStandardBodyActionViewModel] {
        return self.items
    }
}
