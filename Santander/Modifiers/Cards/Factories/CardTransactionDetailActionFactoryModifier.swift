//
//  CardTransactionDetailActionFactoryModifier.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 12/04/2021.
//

import Foundation
import CoreFoundationLib
import Cards

final class CardTransactionDetailActionFactoryModifier: CardTransactionDetailActionFactoryModifierProtocol {
    func customViewType() -> ActionButtonFillViewType {
        let actionViewType: ActionButtonFillViewType = .defaultWithBackground(
            DefaultActionButtonWithBackgroundViewModel(
                title: localized("transaction_buttonOption_expensesDivide"),
                imageKey: "icnBizumWhite",
                renderingMode: .alwaysOriginal,
                titleAccessibilityIdentifier: "transaction_buttonOption_expensesDivide",
                imageAccessibilityIdentifier: "",
                backgroundKey: "imgOperativeBgBizum",
                accessibilityButtonValue: "voiceover_optionSendMoneyMobile"))
        return actionViewType
    }
}
