//
//  TimeLineReceiptEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 20/03/2020.
//

import Foundation

public struct TimeLineReceiptEntity: TimeLineEntityConformable {
    
    public var amount: Decimal
    public var merchant: (code: String, name: String)
    public var fullDate: Date
    public var month: String
    public var ibanEntity: IBANEntity?

    public init (amount: Decimal, merchant: (code: String, name: String), fullDate: Date, month: String, ibanEntity: IBANEntity?) {
        self.amount = amount
        self.merchant = merchant
        self.fullDate = fullDate
        self.month = month
        self.ibanEntity = ibanEntity
    }
}

extension TimeLineReceiptEntity: Equatable {
    public static func == (lhs: TimeLineReceiptEntity, rhs: TimeLineReceiptEntity) -> Bool {
        return lhs.amount == rhs.amount && lhs.fullDate == rhs.fullDate && lhs.ibanEntity?.ibanString == rhs.ibanEntity?.ibanString && lhs.merchant.code == rhs.merchant.code
    }
}
