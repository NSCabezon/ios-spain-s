//
//  AccountTransactionDetailActionModifier.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 13/4/21.
//

import Foundation
import CoreFoundationLib
import Account

final class AccountTransactionDetailActionModifier: AccountTransactionDetailActionModifierProtocol {
    func customViewType() -> ActionButtonFillViewType {
        let actionViewType: ActionButtonFillViewType = .defaultWithBackground(
            DefaultActionButtonWithBackgroundViewModel(
                title: localized("transaction_buttonOption_expensesDivide"),
                imageKey: "icnBizumWhite",
                renderingMode: .alwaysOriginal,
                titleAccessibilityIdentifier: AccessibilityAccountTransactionCell.addSplitExpensesTitle,
                imageAccessibilityIdentifier: AccessibilityAccountTransactionCell.addSplitExpensesImage,
                backgroundKey: "imgOperativeBgBizum",
                accessibilityButtonValue: "voiceover_optionSendMoneyMobile"))
        return actionViewType
    }
}
