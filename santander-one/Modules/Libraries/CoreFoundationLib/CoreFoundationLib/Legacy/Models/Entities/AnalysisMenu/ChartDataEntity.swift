//
//  ChartDataEntity.swift
//  Account
//
//  Created by Ignacio González Miró on 18/05/2020.
//

import Foundation

public struct ChartDataEntity {
    public let income: Double
    public let expense: Double
    public let predictiveExpense: Double
    
    public init(income: Double, expense: Double, predictiveExpense: Double) {
        self.income = income
        self.expense = expense
        self.predictiveExpense = predictiveExpense
    }
}
