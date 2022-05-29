//
//  RecoveryEntity.swift
//  Models
//
//  Created by alvola on 21/10/2020.
//

public final class RecoveryEntity {
    public var offer: OfferEntity?
    public var location: PullOfferLocation?
    public let debtCount: Int
    public let debtTitle: String
    public let amount: Double
    public let level: Int
    
    public init(debtCount: Int, debtTitle: String, amount: Double, offer: OfferEntity?, location: PullOfferLocation?, level: Int) {
        self.debtCount = debtCount
        self.debtTitle = debtTitle
        self.amount = amount
        self.offer = offer
        self.location = location
        self.level = level
    }
}
