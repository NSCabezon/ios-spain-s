//
//  CardOnOffSummaryStepBuilder.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import Operative
import CoreFoundationLib

final class CardOnOffSummaryStepBuilder {
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let viewModel: CardOnOffSummaryViewModel
    private let dependenciesResolver: DependenciesResolver
    
    init(viewModel: CardOnOffSummaryViewModel, dependenciesResolver: DependenciesResolver) {
        self.viewModel = viewModel
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: Body
    
    func addCardInformation() {
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_card"),
                                                             subTitle: viewModel.cardLabel,
                                                             accessibilityIdentifier: "summary_cardInfo")
        self.bodyItems.append(item)
    }
    
    func addOperationDate() {
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_operationDate"),
                                                             subTitle: viewModel.operationDate,
                                                             accessibilityIdentifier: "summary_operationDate")
        self.bodyItems.append(item)
    }
    
    // MARK: Footer
    
    func addGoToCardsHome(withAction action: @escaping () -> Void) {
        let cardsHomeFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnCardMini",
            title: localized("generic_button_myCards"),
            accessibilityIdentifier: "summary_goCardHome",
            action: action
        )
        self.footerItems.append(cardsHomeFooterViewModel)
    }
    
    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let globalPositionFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            accessibilityIdentifier: "summary_goGlobalPosition",
            action: action
        )
        self.footerItems.append(globalPositionFooterViewModel)
    }
    
    func addHelpUsToImprove(withAction action: @escaping () -> Void) {
        let helpToImproveFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            accessibilityIdentifier: "summary_goImprove",
            action: action
        )
        self.footerItems.append(helpToImproveFooterViewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval",
                                                            title: localized("summe_title_perfect"),
                                                            description: self.viewModel.summaryDescription,
                                                            extraInfo: self.viewModel.summaryExtraInfo),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}
