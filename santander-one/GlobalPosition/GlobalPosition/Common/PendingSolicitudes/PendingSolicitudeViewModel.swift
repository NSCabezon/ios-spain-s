//
//  PendingSolicitudeViewModel.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import Foundation
import CoreFoundationLib

final class PendingSolicitudeViewModel: StickyButtonCarrouselViewModelProtocol {
    
    let entity: PendingSolicitudeEntity
    var offer: OfferEntity?
    var location: PullOfferLocation?
    var name: String? {
        return entity.name
    }

    init(entity: PendingSolicitudeEntity, offer: OfferEntity, location: PullOfferLocation) {
        self.entity = entity
        self.offer = offer
        self.location = location
    }
    
    var timeRemaining: String {
        guard
            let startDate = Date().startOfDay().getUtcDate(),
            let expirationDate = entity.expirationDate?.getUtcDate(),
            let days = Calendar.current.dateComponents([.day], from: startDate, to: expirationDate).day
        else {
            return ""
        }
        if days == 0 {
            return localized("contracts_label_today")
        } else if days > 0, days < 3 {
            return localized("contracts_label_hours", [StringPlaceholder(.number, "\(days * 24)")]).text
        } else {
            return localized("contracts_label_days", [StringPlaceholder(.number, "\(days)")]).text
        }
    }
}
 
