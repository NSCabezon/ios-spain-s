//
//  PaymentMethodViewModel.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 08/10/2020.
//

import Foundation
import CoreFoundationLib

enum PaymentMethodViewState {
    case selected
    case deselected
}

struct PaymentMethodHeaderViewModel {
    private var paymentMethodsAvailables = [PaymentMethodEntity]()
    
    init(paymentMethodsAvailables: [PaymentMethodEntity]) {
        self.paymentMethodsAvailables = paymentMethodsAvailables
    }
    
    private var isMonthlyAvailable: Bool {
        return !self.paymentMethodsAvailables.filter { $0.paymentMethodCategory == .monthlyPayment }.isEmpty
    }
    
    var descriptionKey: String {
        return isMonthlyAvailable ? "cardBoarding_text_descriptionPaymentMethod" : "cardBoarding_text_descriptionPaymentMethodNoMonthly"
    }
}

struct PaymentMethodViewModel {
    let title: String
    let description: String
    let viewState: PaymentMethodViewState
    let paymentMethod: PaymentMethodCategory
}

struct PaymentMethodExpandableViewModel {
    let title: String
    let description: String
    let selectAmountDescription: String
    let minimunFee: String
    let placeHolder: String
    let selectedAmount: AmountEntity?
    let amountRangeValues: [Int]
    let viewState: PaymentMethodViewState
    let paymentMethod: PaymentMethodCategory
    
    var amount: String {
        let amount = selectedAmount?.value != 0 ? selectedAmount?.getFormattedValue(withDecimals: 0) ?? "" : "\(self.amountValues[0])"
        return amount
    }
    
    var amountValues: [Decimal] {
        return self.amountRangeValues.map({ Decimal($0) })
    }
    
    var selectedIndex: Int? {
        let selectedAmount = self.selectedAmount?.value ?? 0
        return amountValues.firstIndex(of: selectedAmount)
    }
    
    var selectionButtonIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredButton.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeeButton.rawValue
        }
    }
    
    var titleIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredTitle.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeeTitle.rawValue
        }
    }
    
    var descriptionIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredDescription.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeeDescription.rawValue
        }
    }
    
    var placeholderIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredPlaceholder.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeePlaceholder.rawValue
        }
    }
    
    var textFieldIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredTextField.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeeTextField.rawValue
        }
    }
    
    var selectDescriptionIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredSelectPercentage.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeeSelectAmount.rawValue
        }
    }
    
    var pickerIdentifier: String {
        if paymentMethod == .deferredPayment(selectedAmount) {
            return AccessibilityCardBoarding.ChangePayment.deferredPicker.rawValue
        } else {
            return AccessibilityCardBoarding.ChangePayment.fixedFeePicker.rawValue
        }
    }
}
