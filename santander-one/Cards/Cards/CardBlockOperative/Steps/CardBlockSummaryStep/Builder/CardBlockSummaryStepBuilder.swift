//
//  CardBlockSummaryStepBuilder.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Foundation
import Operative
import CoreFoundationLib

final class CardBlockSummaryStepBuilder {
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private var viewModel: CardBlockSummaryViewModel?
    private let dependenciesResolver: DependenciesResolver
    
    init(viewModel: CardBlockSummaryViewModel?, dependenciesResolver: DependenciesResolver) {
        self.viewModel = viewModel
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: Body
    
    func addCardInformation() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_card"),
                                                             subTitle: viewModel.cardLabel)
        self.bodyItems.append(item)
    }
    
    func addBlockReason() {
        guard let viewModel = self.viewModel else { return }
        if let viewModel = self.viewModel, let extraComment = viewModel.extraComment {
            let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_blockMotive"),
                                                                 subTitle: viewModel.blockReason,
                                                                 info: extraComment)
            self.bodyItems.append(item)
        } else {
            let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_blockMotive"),
                                                                 subTitle: viewModel.blockReason)
            self.bodyItems.append(item)
        }
    }
    
    func addOperationDate() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_operationDate"),
                                                             subTitle: viewModel.operationDate)
        self.bodyItems.append(item)
    }
    
    func addDelivery() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_delivery"),
                                                             subTitle: viewModel.deliveryAddress)
        self.bodyItems.append(item)
    }
    
    // MARK: Footer
    
    func addGoToCardsHome(withAction action: @escaping () -> Void) {
        let cardsHomeFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnCardMini",
            title: localized("generic_button_myCards"),
            action: action
        )
        self.footerItems.append(cardsHomeFooterViewModel)
    }
    
    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let globalPositionFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(globalPositionFooterViewModel)
    }
    
    func addHelpUsToImprove(withAction action: @escaping () -> Void) {
        let helpToImproveFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(helpToImproveFooterViewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval",
                                                            title: localized("summe_title_perfect"),
                                                            description: localized("summary_title_blockCard"),
                                                            extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}
