//
//  LoanHomeOptionViewModel.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/8/21.
//

import Foundation
import CoreFoundationLib

final class LoanHomeOption: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let option: LoanOptionRepresentable
    
    init(_ option: LoanOptionRepresentable) {
        self.option = option
        self.viewType = .defaultButton(
            DefaultActionButtonViewModel(
                title: option.title,
                imageKey: option.imageName,
                titleAccessibilityIdentifier: option.titleIdentifier ?? option.title,
                imageAccessibilityIdentifier: option.imageIdentifier ?? option.imageName,
                accessibilityButtonValue: option.accessibilityIdentifier
        ))
    }
    
    var accessibilityIdentifier: String {
        option.accessibilityIdentifier
    }
}
