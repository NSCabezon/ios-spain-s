//
//  ApplePayOfferViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/9/20.
//

import Foundation
import CoreFoundationLib

final class ApplePayOfferViewModel {
    let welcomeOffer: OfferEntity?
    let confirmationOffer: OfferEntity?
    
    init(welcomeOffer: OfferEntity?, confirmationOffer: OfferEntity?) {
        self.welcomeOffer = welcomeOffer
        self.confirmationOffer = confirmationOffer
    }
    
    var imageUrl: String? {
        return self.welcomeOffer?.banner?.url
    }
}
