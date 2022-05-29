//
//  AnalysisHeaderEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 16/03/2020.
//

import Foundation

public struct AnalysisHeaderEntity {
    public let month: String
    public let incomeText: NSAttributedString
    public let expenseText: NSAttributedString
    public let chartData: ChartDataEntity
    
    public init(month: String, incomeText: NSAttributedString, expenseText: NSAttributedString, chartData: ChartDataEntity) {
        self.month = month
        self.incomeText = incomeText
        self.expenseText = expenseText
        self.chartData = chartData
    }
}
