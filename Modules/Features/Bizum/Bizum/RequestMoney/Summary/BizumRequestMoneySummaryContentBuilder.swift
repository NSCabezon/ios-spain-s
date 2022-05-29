//
//  BizumRequestMoneySummaryContentBuilder.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 10/12/2020.
//

import Foundation
import Operative
import CoreFoundationLib
import ESUI

final class BizumRequestMoneySummaryContentBuilder {
    
    private let operativeData: BizumRequestMoneyOperativeData
    private var bodyItems: [BizumSummaryItem] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BizumRequestMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAmountAndConcept() {
        guard let amount = self.operativeData.bizumSendMoney?.totalAmount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()), info: getOperationConcept(), accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryAmount.rawValue)
        let item = BizumSummaryItem(title: localized("summary_label_totalAmount"),
                                    identifier: 0,
                                    metadata: .standard(data: standardMetadata))
        self.bodyItems.append(item)
    }
    
    func addMultimediaContent() {
        guard let multimediaData = self.operativeData.multimediaData else { return }
        let multimediaViewModel = BizumSummaryMultimediaViewModel(imageText: localized("toolbar_title_attachedImage"),
                                                                 image: multimediaData.image,
                                                                 noteIcon: ESAssets.image(named: "icnNotes"),
                                                                 note: multimediaData.note)
        let item = BizumSummaryItem(title: "",
                                    identifier: 1,
                                    metadata: .multimedia(data: multimediaViewModel))
        self.bodyItems.append(item)
    }
    
    func addDestinationBizumContacts() {
        guard let originAccount = self.operativeData.bizumContactEntity,
            let contacts = self.operativeData.bizumContactEntity,
            let recipientAmount = self.operativeData.bizumSendMoney?.amount else { return }
        let recipients: [BizumSummaryRecipientItemViewModel] = contacts.map {
            var recipientDescription: String = $0.nameOrPhoneToShow
            let statusValue: String = getStatusValue(contactEntity: $0) ?? ""
            return BizumSummaryRecipientItemViewModel(name: recipientDescription,
                                                      status: localized(statusValue),
                                                      amount: recipientAmount, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDestination.rawValue)
        }
        let item = BizumSummaryItem(title: localized("summary_label_destination"),
                                    identifier: 4,
                                    position: .last,
                                    metadata: .recipients(list: recipients))
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
    
    func addGoToBizumHome(withAction action: @escaping () -> Void) {
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
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryBizumViewModel {
        return OperativeSummaryBizumViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1", title: localized("summe_title_perfect"), description: getHeaderDescription(), extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension BizumRequestMoneySummaryContentBuilder {
    func getOperationConcept() -> String {
       guard let concept = self.operativeData.bizumSendMoney?.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
       }
       return concept
    }
    
    private func getHeaderDescription() -> String {
        if let contactsNumber = self.operativeData.bizumContactEntity?.count,
        contactsNumber == 1,
        self.operativeData.typeUserInSimpleSend == .noRegister {
            return localized("summary_label_invitation")
        }
        return localized("summary_item_successfulRequest")
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
