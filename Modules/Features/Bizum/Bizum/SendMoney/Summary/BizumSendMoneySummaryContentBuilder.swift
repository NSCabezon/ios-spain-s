//
//  BizumSendMoneySummaryContentBuilder.swift
//  Bizum
//
//  Created by Jose C. Yebes on 29/09/2020.
//

import Foundation
import Operative
import CoreFoundationLib
import ESUI

final class BizumSendMoneySummaryContentBuilder {
    private let operativeData: BizumSendMoneyOperativeData
    private var bodyItems: [BizumSummaryItem] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BizumSendMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: Content
    func addAmountAndConcept() {
        guard let amount = self.operativeData.bizumSendMoney?.totalAmount else { return }
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
    
    func addMultimediaContent() {
        guard let multimediaData = self.operativeData.multimediaData else { return }
        let multimediaViewModel = BizumSummaryMultimediaViewModel(
            imageText: localized("toolbar_title_attachedImage"),
            image: multimediaData.image,
            noteIcon: ESAssets.image(named: "icnNotes"),
            note: multimediaData.note
        )
        let item = BizumSummaryItem(
            title: "",
            identifier: 1,
            metadata: .multimedia(data: multimediaViewModel)
        )
        self.bodyItems.append(item)
    }
    
    func addOriginAccount() {
        guard let originAccount = self.operativeData.accountEntity else { return }
        if let contactsNumber = self.operativeData.bizumContactEntity?.count,
           contactsNumber == 1,
           self.operativeData.typeUserInSimpleSend == .noRegister {
            return
        }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("summary_label_origin")
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: BizumUtils.boldRegularAttributedString(
                bold: alias,
                regular: availableAmount
            ),
            info: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryOrigin.rawValue
        )
        let item = BizumSummaryItem(
            title: title.camelCased().text,
            identifier: 2,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addTransferType() {
        if let contactsNumber = self.operativeData.bizumContactEntity?.count,
           contactsNumber == 1,
           self.operativeData.typeUserInSimpleSend == .noRegister {
            return
        }
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: localized("summary_text_bizumNoCommissions"),
            info: nil,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummarySendType.rawValue
        )
        let item = BizumSummaryItem(
            title: localized("summary_item_sendType"),
            identifier: 3,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addDestinationBizumContacts() {
        guard let contacts = self.operativeData.bizumContactEntity,
              let recipientAmount = self.operativeData.bizumSendMoney?.amount
        else { return }
        let recipients: [BizumSummaryRecipientItemViewModel] = contacts.map {
            let recipientDescription = $0.nameOrPhoneToShow
            let statusValue: String = getStatusValue(contactEntity: $0) 
            return BizumSummaryRecipientItemViewModel(
                name: recipientDescription,
                status: localized(statusValue),
                amount: recipientAmount, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDestination.rawValue
            )
        }
        let item = BizumSummaryItem(
            title: localized("summary_label_destination"),
            identifier: 4,
            position: .last,
            metadata: .recipients(list: recipients)
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
    func addSendMoneyAgain(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            image: ESAssets.image(named: "icnBizumSummary"),
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
            title: localized("summary_button_recommendBizum"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryBizumViewModel {
        return OperativeSummaryBizumViewModel(
            header: OperativeSummaryStandardHeaderViewModel(
                image: "icnCheckOval1",
                title: localized("summe_title_perfect"),
                description: getHeaderDescription(),
                extraInfo: nil
            ),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension BizumSendMoneySummaryContentBuilder {
    func getOperationConcept() -> String {
        guard let concept = self.operativeData.bizumSendMoney?.concept,
              !concept.isEmpty
        else { return localized("bizum_label_notConcept") }
        return concept
    }
    
    func getHeaderDescription() -> String {
        if let contactsNumber = self.operativeData.bizumContactEntity?.count,
           contactsNumber == 1,
           self.operativeData.typeUserInSimpleSend == .noRegister {
            return localized("summary_label_invitation")
        }
        return localized("summary_label_sentMoneyOk")
    }
    
    func getStatusValue(contactEntity: BizumContactEntity) -> String {
        switch self.operativeData.typeUserInSimpleSend {
        case .register:
            return contactEntity.sendActionValue
        case .noRegister:
            return "summary_label_invited"
        }
    }
}
