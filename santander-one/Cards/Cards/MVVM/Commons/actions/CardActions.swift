//
//  CardActions.swift
//  Pods
//
//  Created by Hernán Villamil on 22/4/22.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib
import OpenCombine

public enum CardActionState: State {
    case idle
    case actionSelected((CardActionType, CardRepresentable))
}

public class CardActions {
    let type: CardActionType
    public let viewType: ActionButtonFillViewType
    public var action: ((CardActionType, CardRepresentable) -> Void)? {
        send(action:card:)
    }
    public let isDisabled: Bool
    public let isFirstDays: Bool
    public let card: CardRepresentable
    public let highlightedInfo: HighlightedInfo?
    public let isUserInteractionEnable: Bool
    public let isDragDisabled: Bool
    public var renderingMode: UIImage.RenderingMode
    private let actionsSubject = CurrentValueSubject<CardActionState, Never>(.idle)
    var actionState: AnyPublisher<CardActionState, Never>
    
    public init(card: CardRepresentable,
                type: CardActionType,
                viewType: ActionButtonFillViewType? = nil,
                action: ((CardActionType, CardRepresentable) -> Void)? = nil,
                isDisabled: Bool = false,
                isFirstDays: Bool = false,
                highlightedInfo: HighlightedInfo? = nil,
                isUserInteractionEnable: Bool = true,
                isDragDisabled: Bool = false,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.card = card
        self.type = type
        self.viewType = viewType ?? type.getViewType(renderingMode)
        self.highlightedInfo = highlightedInfo
        self.isDisabled = isDisabled
        self.isFirstDays = isFirstDays
        self.isUserInteractionEnable = isUserInteractionEnable
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
        self.actionState = actionsSubject.eraseToAnyPublisher()
    }
}

private extension CardActions {
    func send(action: CardActionType, card: CardRepresentable) {
        actionsSubject.send(.actionSelected((action, card)))
    }
}

extension CardActions: ActionButtonViewModelProtocol {
    public var entity: CardRepresentable {
        return card
    }
    
    public var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }
    
    public var actionType: CardActionType {
        return type
    }
}
