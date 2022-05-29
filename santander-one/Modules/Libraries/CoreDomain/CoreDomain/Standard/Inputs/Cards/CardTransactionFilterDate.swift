//
//  CardTransactionFilterDate.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 28/4/22.
//

public struct CardTransactionFilterDate {
    public let startDate: Date
    public let endDate: Date
    public let indexRange: Int
    
    public init(startDate: Date, endDate: Date, indexRange: Int) {
        self.startDate = startDate
        self.endDate = endDate
        self.indexRange = indexRange
    }
}
