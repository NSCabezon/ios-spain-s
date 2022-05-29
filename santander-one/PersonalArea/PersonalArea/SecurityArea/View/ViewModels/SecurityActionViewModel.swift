//
//  SecurityActionViewModel.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 22/01/2020.
import Foundation
import CoreFoundationLib

public enum SecurityActionViewType {
    case switchView
    case actionView
    case videoView
}

public enum SecurityActionAccessibilityIdentifierType {
    case container
    case tooltip
    case action
    case value
    case chevron
}

public protocol SecurityActionViewModelProtocol {
    var action: SecurityActionType? { get set }
    var type: SecurityActionViewType { get set }
}

final class SecurityActionViewModel: SecurityActionViewModelProtocol {
    var type: SecurityActionViewType
    let nameKey: String
    let value: String?
    let tooltipMessage: String?
    var action: SecurityActionType?
    let accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String]
    let externalAction: ExternalAction?
    
    init(action: SecurityActionType? = nil, nameKey: String, value: String? = nil, tooltipMessage: String? = nil, accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String] = [:], externalAction: ExternalAction? = nil) {
        self.nameKey = nameKey
        self.value = value
        self.tooltipMessage = tooltipMessage
        self.action = action
        self.type = .actionView
        self.accessibilityIdentifiers = accessibilityIdentifiers
        self.externalAction = externalAction
    }
}

public final class SecuritySwitchViewModel: SecurityActionViewModelProtocol {
    public var type: SecurityActionViewType
    public var action: SecurityActionType?
    let nameKey: String
    let switchState: Bool
    let tooltipMessage: String?
    let accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String]
    let customAction: CustomAction?

    public init(nameKey: String, switchState: Bool, action: SecurityActionType?, tooltipMessage: String? = nil, accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String] = [:], customAction: CustomAction? = nil) {
        self.nameKey = nameKey
        self.switchState = switchState
        self.action = action
        self.type = .switchView
        self.tooltipMessage = tooltipMessage
        self.accessibilityIdentifiers = accessibilityIdentifiers
        self.customAction = customAction
    }
}

final class SecurityVideoViewModel: SecurityActionViewModelProtocol {
    var type: SecurityActionViewType
    var action: SecurityActionType?
    var offer: OfferEntity
    let accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String]

    init(action: SecurityActionType, offer: OfferEntity, accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String] = [:]) {
        self.action = action
        self.type = .videoView
        self.offer = offer
        self.accessibilityIdentifiers = accessibilityIdentifiers
    }
}
