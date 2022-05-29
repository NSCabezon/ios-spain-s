//
//  OneFlowListItemViewModel.swift
//  Commons
//
//  Created by José María Jiménez Pérez on 14/10/21.
//

import UIKit

public struct OneListFlowItemViewModel {
    public struct Tag {
        public let itemKeyOrValue: String?
        public let tagKeyOrValue: String?
        
        public init(itemKeyOrValue: String?, tagKeyOrValue: String?) {
            self.itemKeyOrValue = itemKeyOrValue
            self.tagKeyOrValue = tagKeyOrValue
        }
    }
    public struct Item {
        public let accessibilityId: String
        public let type: OneListFlowItemType
        public let accessibilityLabel: String?
        public let accessibilityAttributedLabel: NSAttributedString?
        
        public init(type: OneListFlowItemType,
                    accessibilityId: String = "",
                    accessibilityLabel: String? = nil,
                    accessibilityAttributedLabel: NSAttributedString? = nil) {
            self.type = type
            self.accessibilityId = accessibilityId
            self.accessibilityLabel = accessibilityLabel
            self.accessibilityAttributedLabel = accessibilityAttributedLabel
        }
    }
    
    public enum OneListFlowItemType {
        case title(keyOrValue: String?)
        case label(keyOrValue: String?, isBold: Bool)
        case attributedLabel(attributedString: NSAttributedString)
        case image(imageKeyOrUrl: String?)
        case spacing(height: CGFloat)
        case tag(tag: Tag)
        case custom(view: UIView)
    }
    
    public enum Action {
        case edit(action: () -> Void)
        case custom(actionKey: String, action: () -> Void)
        
        public var actionKey: String {
            switch self {
            case .edit:
                return "generic_edit_link"
            case .custom(let actionKey, _):
                return actionKey
            }
        }
        
        public var action: () -> Void {
            switch self {
            case .edit(let action), .custom(_, let action):
                return action
            }
        }
    }
    
    public let isFirstItem: Bool
    public let isLastItem: Bool
    public let shouldShowSeparators: Bool
    public let action: Action?
    public let actionAccessibilityLabel: String?
    public let accessibilitySuffix: String?
    public let items: [Item]
    
    public init(isFirstItem: Bool = true,
                isLastItem: Bool = false,
                items: [Item] = [],
                shouldShowSeparators: Bool = true,
                action: Action? = nil,
                actionAccessibilityLabel: String? = nil,
                accessibilitySuffix: String? = nil) {
        self.isFirstItem = isFirstItem
        self.isLastItem = isLastItem
        self.items = items
        self.shouldShowSeparators = shouldShowSeparators
        self.action = action
        self.actionAccessibilityLabel = actionAccessibilityLabel
        self.accessibilitySuffix = accessibilitySuffix
    }
}
