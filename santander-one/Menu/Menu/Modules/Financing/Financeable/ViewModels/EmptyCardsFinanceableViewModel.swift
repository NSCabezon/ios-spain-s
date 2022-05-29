//
//  EmptyCardsFinanceableViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 06/07/2020.
//

import Foundation
import CoreFoundationLib

struct EmptyCardsFinanceableViewModel {
    let viewModel: CardsCarouselViewModel
    
    init(_ cardViewModel: CardsCarouselViewModel) {
        self.viewModel = cardViewModel
    }
    
    var isSanflixEnabled: Bool {
        return self.viewModel.isSanflixEnabled
    }
    
    var offerViewModel: OfferEntityViewModel? {
        return self.viewModel.offerViewModel
    }
    
    var location: PullOfferLocation? {
        return self.viewModel.location
    }
    
    var isOfferButtonHidden: Bool {
        if self.isSanflixEnabled {
            guard self.offerViewModel != nil else {
                return true
            }
            return false
        } else {
            return false
        }
    }
}
