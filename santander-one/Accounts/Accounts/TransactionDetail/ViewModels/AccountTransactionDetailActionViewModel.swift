//
//  AccountTransactionDetailActionViewModel.swift
//  Accounts
//
//  Created by Jose Carlos Estela Anguita on 20/11/2019.
//

import Foundation
import CoreFoundationLib

public enum AccountTransactionDetailAction {
    case pdf
    case transfers
    case billsAndTaxes
    case returnBill
    case share(Shareable?)
    case splitExpense(SplitableExpenseProtocol?)
    case payBill
}

struct AccountTransactionDetailActionViewModel: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let highlightedInfo: HighlightedInfo?
    let action: () -> Void
    let accessibilityIdentifier: String
    
    init(type: ActionButtonFillViewType? = nil,
         title: String,
         imageNamed: String,
         highlightedInfo: HighlightedInfo? = nil,
         action: @escaping () -> Void,
         accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers) {
        let viewType: ActionButtonFillViewType = type ?? .defaultButton(DefaultActionButtonViewModel(
            title: title,
            imageKey: imageNamed,
            titleAccessibilityIdentifier: accessibilityIdentifier.titleId,
            imageAccessibilityIdentifier: accessibilityIdentifier.imageId
        ))
        self.viewType = viewType
        self.highlightedInfo = highlightedInfo
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier.buttonId
    }
}

struct AccountTransactionDetailActionViewModelAccessibilityIdentifiers {
    let buttonId: String
    let titleId: String
    let imageId: String
}
