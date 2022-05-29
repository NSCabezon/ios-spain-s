//
//  CardSubscriptionDetailConfiguration.swift
//  Cards
//
//  Created by Ignacio González Miró on 7/4/21.
//

import Foundation

public enum CardSubscriptionSeeMoreType {
    case payments
    case historic
}

public enum CardSubscriptionGraphType {
    case graph
    case empty
}

public final class CardSubscriptionDetailConfiguration {
    var detailViewModel: CardSubscriptionViewModel
    
    init(detailViewModel: CardSubscriptionViewModel) {
        self.detailViewModel = detailViewModel
    }
    
    // MARK: Historic property
    var isSeeMorePaymentsOpen: Bool = false
}
