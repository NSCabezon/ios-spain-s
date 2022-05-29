//
//  PullOffersCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 28/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import UI
import CoreDomain

class PullOffersCoordinatorNavigator: ModuleCoordinatorNavigator {
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
}

extension PullOffersCoordinatorNavigator: FullScreenBannerCoordinatorDelegate {
    func executeOffer(offerAction: OfferActionRepresentable) {
        self.executeOffer(action: offerAction, offerId: nil, location: nil)
    }
}
