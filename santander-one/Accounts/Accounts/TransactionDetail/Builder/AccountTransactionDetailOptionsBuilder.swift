//
//  AccountTransactionDetailOptionsBuilder.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 13/03/2020.
//

import CoreFoundationLib

class AccountTransactionDetailOptionsBuilder {
        
    private var items: [AccountTransactionDetailActionViewModel] = []
    
    @discardableResult func addPdf(action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        self.items.append(
            AccountTransactionDetailActionViewModel(
                title: localized("transaction_buttonOption_viewPdf"),
                imageNamed: "icnPdf",
                action: action,
                accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addPdfButton, titleId: AccessibilityAccountTransactionCell.addPdfTitle, imageId: AccessibilityAccountTransactionCell.addPdfImage)
            )
        )
        return self
    }
    
    @discardableResult func addTransfer(action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        self.items.append(
            AccountTransactionDetailActionViewModel(
                title: localized("transaction_buttonOption_transfer"),
                imageNamed: "icnSendMoney",
                action: action,
                accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addTransferButton, titleId: AccessibilityAccountTransactionCell.addTransferTitle, imageId: AccessibilityAccountTransactionCell.addTransferImage))
        )
        return self
    }
    
    @discardableResult func addBill(action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        self.items.append(
            AccountTransactionDetailActionViewModel(
                title: localized("cardsOption_button_billTaxes"),
                imageNamed: "icnBill",
                action: action,
                accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addBillButton, titleId: AccessibilityAccountTransactionCell.addBillTitle, imageId: AccessibilityAccountTransactionCell.addBillImage))
        )
        return self
    }
    
    @discardableResult func addShare(action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        self.items.append(
            AccountTransactionDetailActionViewModel(
                title: localized("generic_button_share"),
                imageNamed: "icnShare",
                action: action,
                accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addShareButton, titleId: AccessibilityAccountTransactionCell.addShareTitle, imageId: AccessibilityAccountTransactionCell.addShareImage))
        )
        return self
    }
    
    @discardableResult func addReturnBill(action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        self.items.append(
            AccountTransactionDetailActionViewModel(
                title: localized("transaction_buttonOption_returnedReceipt"),
                imageNamed: "icnReturnReceipt",
                action: action,
                accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addReturnBillButton, titleId: AccessibilityAccountTransactionCell.addReturnBillTitle, imageId: AccessibilityAccountTransactionCell.addReturnBillImage))
        )
        return self
    }
    
    @discardableResult func addSplitExpenses(customType: ActionButtonFillViewType, action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        let viewModel = AccountTransactionDetailActionViewModel(
            type: customType,
            title: localized("transaction_buttonOption_expensesDivide"),
            imageNamed: "icnDivide",
            action: action,
            accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addSplitExpensesButton, titleId: AccessibilityAccountTransactionCell.addSplitExpensesTitle, imageId: AccessibilityAccountTransactionCell.addSplitExpensesImage))
        self.items.append(viewModel)
        return self
    }
    
    @discardableResult func addPayBill(customType: ActionButtonFillViewType, action: @escaping () -> Void) -> AccountTransactionDetailOptionsBuilder {
        let viewModel = AccountTransactionDetailActionViewModel(
            type: customType,
            title: localized("transaction_buttonOption_receiptsAndTaxes"),
            imageNamed: "icnPayTax",
            action: action,
            accessibilityIdentifier: AccountTransactionDetailActionViewModelAccessibilityIdentifiers(buttonId: AccessibilityAccountTransactionCell.addPayBillButton, titleId: AccessibilityAccountTransactionCell.addPayBillTitle, imageId: AccessibilityAccountTransactionCell.addPayBillImage))
        self.items.append(viewModel)
        return self
    }

    func build() -> [AccountTransactionDetailActionViewModel] {
        return self.items
    }
}
