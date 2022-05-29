//
//  FractionableMovementViewModel.swift
//  Models
//
//  Created by Ignacio González Miró on 14/7/21.
//

import Foundation

public struct FractionableMovementViewModel {
    public let amountEntity: AmountEntity?
    public let identifier: String
    public let name: String
    public let pendingFees: Int
    public let totalFees: Int
    public let operativeDate: String
    public let addTapGesture: Bool
    
    public init(identifier: String, operativeDate: String, name: String, amount: AmountEntity?, pendingFees: Int, totalFees: Int, addTapGesture: Bool) {
        self.identifier = identifier
        self.operativeDate = operativeDate
        self.name = name
        self.amountEntity = amount
        self.pendingFees = pendingFees
        self.totalFees = totalFees
        self.addTapGesture = addTapGesture
    }
    
    public var camelCaseName: String {
        return name.camelCasedString
    }
}
