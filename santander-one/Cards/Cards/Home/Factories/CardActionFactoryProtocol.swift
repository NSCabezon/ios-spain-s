//
//  CardActionFactoryProtocol.swift
//  Cards
//
//  Created by Marcos Álvarez Mesa on 12/1/22.
//

import Foundation
import CoreFoundationLib

public protocol CardActionFactoryProtocol {

    var isOTPExcepted: Bool { get set }
    var isPb: Bool { get set }

    func getOtherOperativesCardActions(for card: CardEntity,
                                       offers: [PullOfferLocation: OfferEntity],
                                       cardActions: (CardAction, CardAction),
                                       isOTPExcepted: Bool) -> [CardActionViewModel]

    func getCardHomeActions(for viewModel: CardViewModel,
                            offers: [PullOfferLocation: OfferEntity],
                            cardActions: (CardAction, CardAction),
                            onlyFourActions: Bool,
                            scaDate: Date?) -> [CardActionViewModel]
}
