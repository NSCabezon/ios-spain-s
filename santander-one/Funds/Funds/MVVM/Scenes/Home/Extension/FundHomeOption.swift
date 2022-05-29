//
//  FundHomeOption.swift
//  Funds
//
import CoreFoundationLib

final class FundHomeOption: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let option: FundOptionRepresentable

    var accessibilityIdentifier: String {
        option.accessibilityIdentifier
    }
    
    init(_ option: FundOptionRepresentable) {
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
}
