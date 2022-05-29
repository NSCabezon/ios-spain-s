//
//  CommercialOffersViewModel.swift
//  Menu
//
//  Created by Ignacio González Miró on 23/12/21.
//

import Foundation
import CoreFoundationLib

struct CommercialOffersViewModel {
    public let commercialOffers: FinanceableInfoViewModel.CommercialOffers
    public var baseUrl: String?
    
    init(_ commercialOffers: FinanceableInfoViewModel.CommercialOffers,
         baseUrl: String?) {
        self.commercialOffers = commercialOffers
        self.baseUrl = baseUrl
    }
    
    var commercialOfferEntity: PullOffersFinanceableCommercialOfferEntity {
        commercialOffers.entity
    }
    
    var offers: [FinanceableInfoViewModel.Offer]? {
        commercialOffers.offers
    }
    
    var hotOffers: [PullOffersFinanceableCommercialOfferPillEntity]? {
        commercialOffers.entity.offers
    }
}
