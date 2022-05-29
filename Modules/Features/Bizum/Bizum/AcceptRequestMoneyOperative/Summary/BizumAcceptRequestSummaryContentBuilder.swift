//
//  BizumAcceptRequestSumaryContentBuilder.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 03/12/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class BizumAcceptRequestSummaryContentBuilder {
    private let operativeData: BizumAcceptMoneyRequestOperativeData
    private var bodyItems: [BizumSummaryItem] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BizumAcceptMoneyRequestOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: Content
    func addAmountAndConcept() {
        guard let amount = self.operativeData.bizumSendMoney?.amount else { return }
        let moneyDecorator = MoneyDecorator(
            amount,
            font: .santander(family: .text, type: .bold, size: 32)
        )
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: moneyDecorator.getFormatedAbsWith1M()
                ?? NSAttributedString(string: amount.getStringValue()),
            info: getOperationConcept(),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryAmount.rawValue
        )
        let item = BizumSummaryItem(
            title: localized("summary_label_totalAmount"),
            identifier: 0,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addOriginAccountAddingAmount(_ addingAmount: Bool) {
        guard let originAccount = self.operativeData.accountEntity else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("summary_label_origin")
        var subtitle = addingAmount ?  self.boldRegularAttributedString(
            bold: alias,
            regular: availableAmount
        ) : NSAttributedString(string: alias)
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: subtitle,
            info: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryOrigin.rawValue
        )
        let item = BizumSummaryItem(
            title: title.camelCased().text,
            identifier: 1,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addTransferType() {
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: localized("summary_text_bizumNoCommissions"),
            info: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummarySendType.rawValue
        )
        let item = BizumSummaryItem(
            title: localized("summary_item_sendType"),
            identifier: 2,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addDestinationBizumContacts() {
        guard let contact = self.operativeData.bizumContacts?[0] else { return }
        let recipientViewModel = BizumSummaryRecipientItemViewModel(
            name: contact.nameOrPhoneToShow,
            status: contact.validateSendAction ?? "",
            amount: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDestination.rawValue
        )
        let item = BizumSummaryItem(
            title: localized("summary_label_destination"),
            identifier: 3,
            metadata: .recipients(list: [recipientViewModel])
        )
        self.bodyItems.append(item)
    }
    
    func addComment() {
        guard let comment = self.operativeData.multimediaData?.note else { return }
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: comment,
            info: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryComment.rawValue
        )
        let item = BizumSummaryItem(
            title: localized("summary_item_commentary"),
            identifier: 4,
            metadata: .standard(data: standardMetadata)
        )
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
            guard self.bodyItems.count - 1 == offset else { return element }
            return BizumSummaryItem(
                title: element.title,
                identifier: element.id,
                position: .last,
                metadata: element.metadata
            )
        }
        return OperativeSummaryBizumViewModel(
            header: OperativeSummaryStandardHeaderViewModel(
                image: "icnCheckOval1",
                title: localized("summe_title_perfect"),
                description: getHeaderDescription(),
                extraInfo: nil
            ),
            bodyItems: bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension BizumAcceptRequestSummaryContentBuilder {
    /// Returns a string with the following format: `bold (regular)`
    /// - Parameters:
    ///   - bold: The bold part of the string
    ///   - regular: The regular part of the string
    func boldRegularAttributedString(bold: String, regular: String) -> NSAttributedString {
        let regularWithParenthesis = "(" + regular + ")"
        let builder = TextStylizer.Builder(fullText: bold + " " + regularWithParenthesis)
        let boldStyle = TextStylizer.Builder.TextStyle(word: bold)
        let regularStyle = TextStylizer.Builder.TextStyle(word: regularWithParenthesis)
        return builder.addPartStyle(
            part: boldStyle
                .setColor(.lisboaGray)
                .setStyle(.santander(family: .text, type: .bold, size: 14)
                )
        ).addPartStyle(
            part: regularStyle
                .setColor(.lisboaGray)
                .setStyle(.santander(family: .text, size: 14)
                )
        ).build()
    }
    
    func getOperationConcept() -> String {
        guard
            let concept = self.operativeData.operation?.concept,
            !concept.isEmpty
        else { return localized("bizum_label_notConcept") }
        return concept
    }
    
    private func getHeaderDescription() -> String {
        return localized("summary_item_requestAcceptedSuccessfully")
    }
}
