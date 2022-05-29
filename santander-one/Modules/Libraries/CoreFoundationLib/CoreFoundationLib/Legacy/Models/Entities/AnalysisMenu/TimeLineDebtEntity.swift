//
//  TimeLineDebtEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 20/03/2020.
//

import Foundation

public struct TimeLineDebtEntity {
    public var fullDate: Date
    public var month: String
    public let amount: Decimal
    public let ibanEntity: IBANEntity?
    public let description: String
    
    public init(fullDate: Date, month: String, amount: Decimal, ibanEntity: IBANEntity?, description: String) {
        self.fullDate = fullDate
        self.month = month
        self.amount = amount
        self.ibanEntity = ibanEntity
        self.description = description
    }
}

extension TimeLineDebtEntity: Equatable {
    public static func == (lhs: TimeLineDebtEntity, rhs: TimeLineDebtEntity) -> Bool {
        return lhs.amount == rhs.amount && lhs.fullDate == rhs.fullDate && lhs.ibanEntity?.ibanString == rhs.ibanEntity?.ibanString
    }
}
