//
//  CheckboxViewModel.swift
//  Models
//
//  Created by Cristobal Ramos Laina on 15/9/21.
//

import Foundation

public final class OneCheckboxViewModel {
    public var status: OneStatus
    public let titleKey: String
    public let isSelected: Bool
    public let accessibilityActivatedLabel: String?
    public let accessibilityNoActivatedLabel: String?
    public let accessibilitySuffix: String?

    public init(status: OneStatus,
                titleKey: String,
                isSelected: Bool = false,
                accessibilityActivatedLabel: String? = nil,
                accessibilityNoActivatedLabel: String? = nil,
                accessibilitySuffix: String? = nil) {
        self.status = status
        self.titleKey = titleKey
        self.isSelected = isSelected
        self.accessibilityActivatedLabel = accessibilityActivatedLabel
        self.accessibilityNoActivatedLabel = accessibilityNoActivatedLabel
        self.accessibilitySuffix = accessibilitySuffix
    }
}
