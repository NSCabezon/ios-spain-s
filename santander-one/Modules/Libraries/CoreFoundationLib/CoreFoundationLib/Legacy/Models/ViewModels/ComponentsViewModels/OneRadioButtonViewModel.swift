//
//  OneRadioButtonViewModel.swift
//  Models
//
//  Created by Cristobal Ramos Laina on 20/9/21.
//

import Foundation

public final class OneRadioButtonViewModel {
    public var status: OneStatus
    public let titleKey: String
    public let subtitleKey: String?
    public let additionalInfoKey: String?
    public let isSelected: Bool
    public let bottomSheetView: UIView?
    public var accessibilitySuffix: String?
    public var titleAccessibilityLabel: String?
    public var tooltipAccessibilityLabel: String?

    public init(status: OneStatus,
                titleKey: String,
                subtitleKey: String? = nil,
                additionalInfoKey: String? = nil,
                isSelected: Bool = false,
                bottomSheetView: UIView? = nil,
                accessibilitySuffix: String? = nil,
                titleAccessibilityLabel: String? = nil,
                tooltipAccessibilityLabel: String? = nil) {
        self.status = status
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.additionalInfoKey = additionalInfoKey
        self.isSelected = isSelected
        self.bottomSheetView = bottomSheetView
        self.accessibilitySuffix = accessibilitySuffix
        self.titleAccessibilityLabel = titleAccessibilityLabel
        self.tooltipAccessibilityLabel = tooltipAccessibilityLabel
    }
    
    public var isTooltipHidden: Bool {
        return self.bottomSheetView != nil ? false : true
    }
    
    public func setAccessibilityInfo(accessibilityInfo: (titleLabel: String, tooltipLabel: String)) {
        self.titleAccessibilityLabel = accessibilityInfo.titleLabel
        self.tooltipAccessibilityLabel = accessibilityInfo.tooltipLabel
    }
}
