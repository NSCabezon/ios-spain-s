//
//  OneLabelViewModel.swift
//  Account
//
//  Created by Angel Abad Perez on 21/9/21.
//

import Foundation

public final class OneLabelViewModel {
    public let type: LabelType
    public let mainTextKey: String
    public let actionTextKey: String?
    public let actualCounterLabel: String?
    public let maxCounterLabel: String?
    public let helperAction: (() -> Void)?
    public let action: (() -> Void)?
    public let accessibilitySuffix: String?
    public let viewAccessibility: String?
    public let actionTextLabelKey: String?
    public let counterLabelsAccessibilityText: String?
    
    public init(type: LabelType,
                mainTextKey: String,
                actionTextKey: String? = nil,
                actualCounterLabel: String? = nil,
                maxCounterLabel: String? = nil,
                helperAction: (() -> Void)? = nil,
                action: (() -> Void)? = nil,
                accessibilitySuffix: String? = nil,
                viewAccessibility: String? = nil,
                actionTextLabelKey: String? = nil,
                counterLabelsAccessibilityText: String? =  nil) {
        self.type = type
        self.mainTextKey = mainTextKey
        self.actionTextKey = actionTextKey
        self.actualCounterLabel = actualCounterLabel
        self.maxCounterLabel = maxCounterLabel
        self.helperAction = helperAction
        self.action = action
        self.accessibilitySuffix = accessibilitySuffix
        self.viewAccessibility = viewAccessibility
        self.actionTextLabelKey = actionTextLabelKey
        self.counterLabelsAccessibilityText = counterLabelsAccessibilityText
    }
    
    public enum LabelType {
        case normal
        case helper
        case action
        case helperAndAction
        case counter
    }
}
