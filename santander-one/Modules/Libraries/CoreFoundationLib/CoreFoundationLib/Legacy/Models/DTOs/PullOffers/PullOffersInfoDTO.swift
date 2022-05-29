//
//  PullOffersInfoDTO.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

import CoreDomain

public struct PullOffersInfoDTO {
    public let offerId: String
    public let userId: String
    public var expired: Bool
    public var iterations: Int

    public init(offerId: String, userId: String, expired: Bool = false, iterations: Int = 0) {
        self.offerId = offerId
        self.userId = userId
        self.expired = expired
        self.iterations = iterations
    }
}

extension PullOffersInfoDTO: PullOfferInfoRepresentable {}
