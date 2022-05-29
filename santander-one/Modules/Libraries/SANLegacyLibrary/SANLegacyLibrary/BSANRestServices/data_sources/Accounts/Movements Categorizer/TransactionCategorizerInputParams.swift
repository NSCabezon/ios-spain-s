//
//  MovementCategorizerParameter.swift
//
//  Created by Boris Chirino Fernandez on 22/12/2020.
//
import Foundation
public struct TransactionCategorizerInputParams: Codable {
    let movementId: String
    let movementDescription: String
    let amount: String
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case movementId = "idMov"
        case movementDescription = "titleMov"
        case amount = "amountMov"
        case date = "dateMov"
    }
    
    public init(movementId: String, movementDescription: String, amount: Decimal, date: Date) {
        self.movementId = movementId
        self.movementDescription = movementDescription
        self.amount = AmountFormats.getValueForWS(value: amount)
        self.date = DateFormats.toString(date: date, output: .YYYYMMDD_HHmmssSSST)
    }
}
