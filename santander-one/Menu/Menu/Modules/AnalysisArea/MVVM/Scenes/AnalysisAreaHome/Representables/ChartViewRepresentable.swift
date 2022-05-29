//
//  ChartViewRepresentable.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 2/3/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

protocol ChartViewRepresentable {
    var expenseData: AnalysisAreaCategoriesRepresentable { get }
    var paymentData: AnalysisAreaCategoriesRepresentable { get }
    var incomeData: AnalysisAreaCategoriesRepresentable { get }
}

struct ChartViewRepresented {
    var summary: [AnalysisAreaSummaryItemRepresentable]
    private var data: [Category] {
        return summary.map { Category(representable: $0) }
    }
    private var categorizer = AnalysisAreaCategorizer()
    
    public init (summary: [AnalysisAreaSummaryItemRepresentable]) {
        self.summary = summary
    }
    
    private func calculatePercentages(of categories: [Category]) -> [Category] {
        let totalValue = categories.reduce(0) { $0 + ($1.amount.value ?? 0) }.doubleValue
        
        return categories.map {
            let relativeValue = (abs($0.amount.value?.doubleValue ?? 0.0)) / (abs(totalValue) * 100)
            return Category(type: $0.type,
                     percentage: relativeValue,
                     categorization: $0.categorization,
                     movements: $0.movements,
                     currency: $0.currency,
                     amount: $0.amount)
        }
        return categories
    }
}

extension ChartViewRepresented: ChartViewRepresentable {
    var expenseData: AnalysisAreaCategoriesRepresentable {
        let expenseData = data.filter { $0.categorization == .expenses }
        return categorizer.calculateExpenseOrIncomeCategories(expenseData, categorization: .expenses)
    }
    
    var paymentData: AnalysisAreaCategoriesRepresentable {
        let paymentData = data.filter { $0.categorization == .payments }
        return categorizer.calculateExpenseOrIncomeCategories(paymentData, categorization: .payments)
    }
    
    var incomeData: AnalysisAreaCategoriesRepresentable {
        let incomeData = data.filter { $0.categorization == .incomes }
        return categorizer.calculateExpenseOrIncomeCategories(incomeData, categorization: .incomes)
    }
}

extension ChartViewRepresented: ChartsCollectionViewRepresentable {
    var tabData: [Int: [AnalysisAreaCategoriesRepresentable]] {
        var tabs: [Int: [AnalysisAreaCategoriesRepresentable]] = [:]
        tabs[0] = [expenseData, paymentData]
        tabs[1] = [incomeData]
        return tabs
    }
}
