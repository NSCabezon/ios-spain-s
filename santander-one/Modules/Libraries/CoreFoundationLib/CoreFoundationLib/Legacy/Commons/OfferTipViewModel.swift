//
//  OfferTipViewModel.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/10/2020.
//

import CoreDomain

public struct OfferTipViewModel {
    public let offer: OfferRepresentable?
    public let baseUrl: String?
    public let representable: PullOfferTipRepresentable
    
    public init(_ representable: PullOfferTipRepresentable, baseUrl: String?) {
        self.offer = representable.offerRepresentable
        self.baseUrl = baseUrl
        self.representable = representable
    }
    
    public var imageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let icon = self.representable.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
}
