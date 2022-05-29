//
//  BizumDonationSummaryContentBuilder.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/02/2021.
//

import Foundation
import Operative
import CoreFoundationLib
import ESUI

final class BizumDonationSummaryContentBuilder {
    
    private let operativeData: BizumDonationOperativeData
    private var bodyItems: [BizumSummaryItem] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: BizumDonationOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAmountAndConcept() {
        guard let amount = self.operativeData.bizumSendMoney?.totalAmount else { return }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let standardMetadata = OperativeSummaryBizumBodyItemViewModel(
            subTitle: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue()),
            info: self.getOperationConcept(),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryAmount.rawValue
        )
        let item = BizumSummaryItem(title: localized("generic_hint_amount"),
                                    identifier: 0,
                                    metadata: .standard(data: standardMetadata))
        self.bodyItems.append(item)
    }
    
    func addMultimediaContent() {
        guard let multimediaData = self.operativeData.multimediaData else { return }
        let multimediaViewModel = BizumSummaryMultimediaViewModel(imageText: localized("summary_label_attachedImage"),
                                                                 image: multimediaData.image,
                                                                 noteIcon: ESAssets.image(named: "icnNotes"),
                                                                 note: multimediaData.note)
        let item = BizumSummaryItem(title: "",
                                    identifier: 1,
                                   metadata: .multimedia(data: multimediaViewModel))
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
    
    func addOriginAccount() {
        guard let originAccount = self.operativeData.accountEntity else { return }
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
            identifier: 3,
            metadata: .standard(data: standardMetadata)
        )
        self.bodyItems.append(item)
    }
    
    func addDestination() {
        guard let organization = self.operativeData.organization else { return }
        let name = !(organization.name.isEmpty) ? organization.name : organization.alias
        let item = BizumSummaryItem(title: localized("confirmation_label_destination"),
                                    identifier: 4,
                                    position: .last,
                                    metadata: .organization(data: BizumSummaryOrganizationViewModel(name: name,
                                                                                                    alias: organization.alias,
                                                                                                    identifier: organization.identifier,
                                                                                                    baseUrl: self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL,
                                                                                                    colorsByNameViewModel: self.getColorsByNameViewModel())
                                    )
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
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1",
                                                            title: localized("summe_title_perfect"),
                                                            description: localized("summary_label_donationCompleted"),
                                                            extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension BizumDonationSummaryContentBuilder {
    func getOperationConcept() -> String {
        guard let concept = self.operativeData.bizumSendMoney?.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
       }
       return concept
    }
    
    func getColorsByNameViewModel() -> ColorsByNameViewModel? {
        guard let organization = self.operativeData.organization else { return nil }
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let name = organization.name
        let colorType = colorsEngine.get(name)
        let colorsByNameViewModel = ColorsByNameViewModel(colorType)
        return colorsByNameViewModel
    }
}
