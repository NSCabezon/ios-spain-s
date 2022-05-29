//
//  BigOfferViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 14/07/2020.
//

import Foundation
import CoreFoundationLib

struct BigOfferViewModel {
    private let viewModel: FinanceableInfoViewModel.BigOffer
    
    init(_ viewModel: FinanceableInfoViewModel.BigOffer) {
        self.viewModel = viewModel
    }
    
    var offer: OfferEntity? {
        return viewModel.offer?.offer
    }
    
    var imageURL: String? {
        return self.offer?.banner?.dto.url
    }
    
    var offerViewModel: OfferEntityViewModel? {
        guard let offer = self.offer else { return nil }
        return OfferEntityViewModel(entity: offer)
    }
}
