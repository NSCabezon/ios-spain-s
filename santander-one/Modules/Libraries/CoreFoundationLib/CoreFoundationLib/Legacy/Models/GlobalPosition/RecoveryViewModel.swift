//
//  RecoveryViewModel.swift
//  Models
//
//  Created by alvola on 14/10/2020.
//

public final class RecoveryViewModel: StickyButtonCarrouselViewModelProtocol {
    public var offer: OfferEntity?
    public var location: PullOfferLocation?
    public let debtCount: Int
    public let debtTitle: String
    public let amount: String

    public init(debtCount: Int,
                debtTitle: String,
                amount: String,
                offer: OfferEntity?,
                location: PullOfferLocation?) {
        self.debtCount = debtCount
        self.debtTitle = debtTitle
        self.amount = amount
        self.offer = offer
        self.location = location
    }
}
