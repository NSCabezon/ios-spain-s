//
//  BizumRefundMoneySummaryContentBuilder.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 11/12/20.
//

import Foundation
import Operative
import CoreFoundationLib

final class BizumRefundMoneySummaryContentBuilder {
    private let operativeData: BizumRefundMoneyOperativeData
    private var bodyItems: [BizumSummaryItem] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BizumRefundMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: Content
    func addAmountAndConcept() {
        let amount = self.operativeData.totalAmount
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()), info: getOperationConcept(), accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryAmount.rawValue)
        let item = BizumSummaryItem(title: localized("summary_label_totalAmount"),
                                    identifier: 0,
                                    metadata: .standard(data: standardMetadata))
        self.bodyItems.append(item)
    }
    
    func addDestinationBizumContacts() {
        let contact = BizumContactEntity(
            identifier: self.operativeData.operation.emitterId ?? "",
            name: self.operativeData.operation.emitterAlias ?? "",
            phone: self.operativeData.operation.emitterId ?? ""
        )
        var recipientDescription: String = contact.nameToShow
        let recipientViewModel =  BizumSummaryRecipientItemViewModel(name: recipientDescription,
                                                                     status: contact.validateSendAction ?? "",
                                                                     amount: nil, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDestination.rawValue)
        let item = BizumSummaryItem(title: localized("summary_item_receivedFrom"),
                                    identifier: 2,
                                    metadata: .recipients(list: [recipientViewModel]))
        self.bodyItems.append(item)
    }
    
    func addComment() {
        guard let comment = self.operativeData.comment else { return }
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(subTitle: comment, info: nil, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryComment.rawValue)
        let item = BizumSummaryItem(title: localized("summary_item_commentary"),
                                    identifier: 3,
                                    metadata: .standard(data: standardMetadata))
        self.bodyItems.append(item)
    }
    
    func addDate() {
        guard let date = self.operativeData.operation.date else { return }
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(subTitle: self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: date, outputFormat: .dd_MMM_yyyy) ?? "", info: nil, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDate.rawValue)
        let item = BizumSummaryItem(title: localized("summary_item_shippingDate"),
                                    identifier: 4,
                                    metadata: .standard(data: standardMetadata))
        self.bodyItems.append(item)
    }
    
    // MARK: Actions
    func addShare(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardBodyActionViewModel(
            image: "icnShare",
            title: localized("generic_button_share"),
            action: action
        )
        self.bodyActionItems.append(viewModel)
    }
    
    // MARK: Footer
    func addGoToBizumHome(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnPayment",
            title: localized("generic_button_anotherSendMoney"),
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

    func build() -> OperativeSummaryBizumViewModel {
        let bodyItems: [BizumSummaryItem] = self.bodyItems.enumerated().map { offset, element in
            guard self.bodyItems.count - 1  == offset else { return element }
            return BizumSummaryItem(title: element.title,
                                    identifier: element.id,
                                    position: .last,
                                    metadata: element.metadata)
        }
        return OperativeSummaryBizumViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1", title: localized("summe_title_perfect"), description: localized("summary_item_successfullyReceivedReturned"), extraInfo: nil),
            bodyItems: bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension BizumRefundMoneySummaryContentBuilder {
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
        guard let concept = self.operativeData.operation.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
       }
       return concept
    }
}
