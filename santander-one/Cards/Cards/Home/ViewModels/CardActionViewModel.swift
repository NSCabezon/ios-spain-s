//
//  CardActionViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/29/19.
//

import Foundation
import CoreFoundationLib
import UI

public struct CardActionViewModel {
    let type: OldCardActionType
    public let viewType: ActionButtonFillViewType
    public let action: ((OldCardActionType, CardEntity) -> Void)?
    public let isDisabled: Bool
    public let isFirstDays: Bool
    public let entity: CardEntity
    public let highlightedInfo: HighlightedInfo?
    public let isUserInteractionEnable: Bool
    public let isDragDisabled: Bool
    public let renderingMode: UIImage.RenderingMode
    
    public init(entity: CardEntity,
                type: OldCardActionType,
                viewType: ActionButtonFillViewType? = nil,
                action: ((OldCardActionType, CardEntity) -> Void)?,
                isDisabled: Bool = false,
                isFirstDays: Bool = false,
                highlightedInfo: HighlightedInfo? = nil,
                isUserInteractionEnable: Bool = true,
                isDragDisabled: Bool = false,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.entity = entity
        self.type = type
        self.viewType = viewType ?? type.getViewType(renderingMode)
        self.action = action
        self.highlightedInfo = highlightedInfo
        self.isDisabled = isDisabled
        self.isFirstDays = isFirstDays
        self.isUserInteractionEnable = isUserInteractionEnable
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
    
    func copyViewModel(entity: CardEntity? = nil,
                       type: OldCardActionType? = nil,
                       viewType: ActionButtonFillViewType? = nil,
                       action: ((OldCardActionType, CardEntity) -> Void)? = nil,
                       isDisabled: Bool? = nil,
                       isFirstDays: Bool? = nil,
                       highlightedInfo: HighlightedInfo? = nil,
                       isUserInteractionEnable: Bool? = nil,
                       isDragDisabled: Bool? = nil,
                       renderingMode: UIImage.RenderingMode? = nil) -> CardActionViewModel {
        return CardActionViewModel(
            entity: entity ?? self.entity,
            type: type ?? self.type,
            viewType: viewType ?? self.viewType,
            action: action ?? self.action,
            isDisabled: isDisabled ?? self.isDisabled,
            isFirstDays: isFirstDays ?? self.isFirstDays,
            highlightedInfo: highlightedInfo ?? self.highlightedInfo,
            isUserInteractionEnable: isUserInteractionEnable ?? self.isUserInteractionEnable,
            isDragDisabled: isDragDisabled ?? self.isDragDisabled,
            renderingMode: renderingMode ?? self.renderingMode
        )
    }
}

extension CardActionViewModel: ActionButtonViewModelProtocol {
    public var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }
    
    public var actionType: OldCardActionType {
        return type
    }
}

extension CardActionViewModel: Equatable {
    public static func == (lhs: CardActionViewModel, rhs: CardActionViewModel) -> Bool {
        return lhs.viewType == rhs.viewType
    }
}

extension OldCardActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: OldCardActionType, rhs: OldCardActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

func ~= (values: [OldCardActionType], rhs: OldCardActionType) -> Bool {
    return values.contains(rhs)
}
