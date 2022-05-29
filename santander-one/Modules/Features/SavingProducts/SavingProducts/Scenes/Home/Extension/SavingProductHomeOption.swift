//
//  SavingProductHomeOption.swift
//  SavingProducts
//
//  Created by José Norberto Hidalgo Romero on 23/2/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class SavingProductHomeOption: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let option: SavingProductOptionRepresentable
    
    init(_ option: SavingProductOptionRepresentable) {
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
