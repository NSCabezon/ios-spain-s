//
//  CardsCarouselViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 03/07/2020.
//

import Foundation
import CoreFoundationLib

struct CardsCarouselViewModel {
    private let financeableInfoCarousel: FinanceableInfoViewModel.CardsCarousel
    
    init(_ info: FinanceableInfoViewModel.CardsCarousel) {
        self.financeableInfoCarousel = info
    }
    
    var isSanflixEnabled: Bool {
        return self.financeableInfoCarousel.isSanflixEnabled
    }
    
    var offer: OfferEntity? {
        return self.financeableInfoCarousel.offer?.offer
    }
    
    var location: PullOfferLocation? {
        return self.financeableInfoCarousel.offer?.location
    }
    
    var cards: [CardFinanceableViewModel] {
        let viewModels = self.financeableInfoCarousel.cards.map(CardFinanceableViewModel.init)
        _ = viewModels.sorted(by: {$0.name < $1.name})
        return viewModels
    }
    
    var isCardSelectorHidden: Bool {
        guard !cards.isEmpty, cards.count > 1 else {
            return true
        }
        return false
    }
    
    var selectedCard: CardFinanceableViewModel? {
        guard !self.cards.isEmpty else {
            return nil
        }
        return self.cards[0]
    }
    
    var offerViewModel: OfferEntityViewModel? {
        guard let offer = self.offer else { return nil }
        return OfferEntityViewModel(entity: offer)
    }
}
