//
//  PendingSolicitudeViewModel.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import Foundation

public final class PendingSolicitudeInboxViewModel {
    public let entity: PendingSolicitudeEntity
    public let offer: OfferEntity?
    public let name: String?
    public let action: ((OfferEntity?) -> Void)?

    public init(_ entity: PendingSolicitudeEntity,
                offer: OfferEntity?,
                action: ((OfferEntity?) -> Void)?) {
        self.entity = entity
        self.offer = offer
        self.name = entity.name
        self.action = action
    }
}
 
