//
//  extension+HomeCrossSelling.swift
//  Cards
//
//  Created by Margaret López Calderón on 6/8/21.
//

import Foundation
import CoreFoundationLib

extension CardsHomePresenter {
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().cards
    }
    
    // MARK: - Pull offers

    var cardTransactionPullOffersUseCase: CardTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: CardTransactionPullOfferConfigurationUseCase.self)
    }
    
}
