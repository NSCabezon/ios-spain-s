//
//  CardTransactionDetailActionBuilder.swift
//
//  Created by Carlos Monfort Gómez on 03/12/2019.
//

import Foundation
import CoreFoundationLib

class CardTransactionDetailActionBuilder {
    private var actions: [CardActionViewModel] = []
    private var entity: CardEntity
    
    init(entity: CardEntity) {
        self.entity = entity
    }
    
    func addOn(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        let actionButtonViewModel = DefaultActionButtonViewModel(
            title: "frequentOperative_label_turnOn",
            imageKey: "icnOn",
            titleAccessibilityIdentifier: AccessibilityOtherOperatives.btnCardOn.rawValue,
            imageAccessibilityIdentifier: "icnOn")
        let onAction = CardActionViewModel(
            entity: entity,
            type: .onCard,
            viewType: .defaultButton(actionButtonViewModel),
            action: action
        )
        actions.append(onAction)
    }
    
    func addOff(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        let actionButtonViewModel = DefaultActionButtonViewModel(
            title: "transaction_buttonOption_cardOff",
            imageKey: "icnOff",
            titleAccessibilityIdentifier: AccessibilityOtherOperatives.btnCardOff.rawValue,
            imageAccessibilityIdentifier: "icnOff")
        let offAction = CardActionViewModel(
            entity: entity,
            type: .offCard,
            viewType: .defaultButton(actionButtonViewModel),
            action: action
        )
        actions.append(offAction)
    }
    
    func addEnable(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        let enable = CardActionViewModel(
            entity: entity,
            type: .enable,
            action: action
        )
        actions.append(enable)
    }
    
    func addShare(viewModel: OldCardTransactionDetailViewModel, _ action: @escaping (OldCardActionType, CardEntity) -> Void, _ isActionDisabled: Bool) {
        let share = CardActionViewModel(
            entity: entity,
            type: .share(viewModel),
            action: action,
            isDisabled: isActionDisabled
        )
        actions.append(share)
    }
    
    func addFraud(offer: OfferEntity, _ action: @escaping (OldCardActionType, CardEntity) -> Void, _ isActionDisabled: Bool) {
        let fraud = CardActionViewModel(
            entity: entity,
            type: .fraud(offer),
            action: action,
            isDisabled: isActionDisabled
        )
        actions.append(fraud)
    }
    
    func addPrepaid(_ action: @escaping (OldCardActionType, CardEntity) -> Void, _ isActionDisabled: Bool) {
        let prepaid = CardActionViewModel(
            entity: entity,
            type: .chargePrepaid,
            action: action,
            isDisabled: isActionDisabled
        )
        actions.append(prepaid)
    }
    
    func build() -> [CardActionViewModel] {
        return actions
    }
    
    func addCustom(customType: ActionButtonFillViewType, viewModel: OldCardTransactionDetailViewModel, _ action: @escaping (OldCardActionType, CardEntity) -> Void, _ isActionDisabled: Bool) {
        let custom = CardActionViewModel(
            entity: entity,
            type: .divide(viewModel),
            viewType: customType,
            action: action,
            isDisabled: isActionDisabled
        )
        actions.append(custom)
    }
    
    func addDivideCustom(cardTransactionDetailActionModifier: CardTransactionDetailActionFactoryModifierProtocol, viewModel: OldCardTransactionDetailViewModel, action: @escaping (OldCardActionType, CardEntity) -> Void, isActionDisabled: Bool) {
        let customViewType = cardTransactionDetailActionModifier.customViewType()
        self.addCustom(customType: customViewType, viewModel: viewModel, action, isActionDisabled)
    }
    
    func addPDFDetail(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        let pdfDetail = CardActionViewModel(
            entity: entity,
            type: .pdfDetail,
            action: action
        )
        actions.append(pdfDetail)
    }
}
