//
//  InboxActionViewModel.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import Foundation

public struct InboxActionViewModel {
    public var imageName: String
    public var title: String
    public var description: String
    public var notificationAlert: String?
    public var extras: InboxActionExtras?
    public var accessibilityIdentifier: String?
    public var action: ((InboxActionExtras?) -> Void)?
    public var offerAction: ((OfferEntity?) -> Void)?
    public var actionType: InboxActionType?
    
    public init(imageName: String,
                title: String,
                description: String,
                notificationAlert: String? = nil,
                extras: InboxActionExtras? = nil,
                accessibilityIdentifier: String? = nil,
                action: ((InboxActionExtras?) -> Void)? = nil,
                offerAction: ((OfferEntity?) -> Void)? = nil,
                actionType: InboxActionType? = nil) {
        self.imageName = imageName
        self.title = title
        self.description = description
        self.notificationAlert = notificationAlert
        self.extras = extras
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.offerAction = offerAction
        self.actionType = actionType
    }
}

public struct InboxActionExtras {
    public var pendingSolicitude: PendingSolicitudeInboxViewModel?
    public var offer: OfferEntity?
    public var action: ()?
    
    public init(pendingSolicitude: PendingSolicitudeInboxViewModel? = nil,
                offer: OfferEntity? = nil,
                action: ()? = nil) {
        self.pendingSolicitude = pendingSolicitude
        self.offer = offer
        self.action = action
    }
}

public enum InboxActionType {
    case custom(InboxActionEnumerationCapable)
}

public protocol InboxActionEnumerationCapable {}
