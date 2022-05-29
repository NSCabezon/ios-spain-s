//
//  TimeLineSubscriptionEntity.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 21/04/2020.
//

import Foundation

public struct TimeLineSubscriptionEntity: TimeLineEntityConformable {
    public var amount: Decimal
    public var merchant: (code: String, name: String)
    public var ibanEntity: IBANEntity?
    public var fullDate: Date
    public var month: String
    public let name: String
    
    public init(amount: Decimal, merchant: (code: String, name: String), ibanEntity: IBANEntity?, fullDate: Date, month: String, name: String) {
        self.amount = amount
        self.merchant = merchant
        self.ibanEntity = ibanEntity
        self.fullDate = fullDate
        self.month = month
        self.name = name
    }
}
