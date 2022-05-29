//
//  AnalysisAreaCategorizer.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 2/3/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class AnalysisAreaCategorizer {
    var categories = [FinancialHealthSummaryItemRepresentable]()
    var others = [Category]()
    private let orderedExpensePaymentCategories: [String] = [
        "banksAndInsurances",
        "home",
        "purchasesAndFood",
        "health",
        "education",
        "leisure",
        "transport",
        "atms",
        "managements",
        "taxes"
    ]
    
    private let orderedIncomeCategories: [String] = [
        "payroll",
        "helps",
        "atms",
        "saving",
        "home"
    ]
}

extension AnalysisAreaCategorizer {
    func compareEqualCategory(_ sector1: Category, _ sector2: Category, categorization: AnalysisAreaCategorization) -> Bool {
        let orderedCategories = categorization == .incomes ? orderedIncomeCategories : orderedExpensePaymentCategories
        guard let index1 = orderedCategories.firstIndex(of: sector1.type.rawValue),
              let index2 = orderedCategories.firstIndex(of: sector2.type.rawValue)
        else {
            return true
        }
        return index1 < index2
    }
    
    func compareCategories(_ sector1: Category, _ sector2: Category, categorization: AnalysisAreaCategorization) -> Bool {
        if sector1.percentage == sector2.percentage {
            return compareEqualCategory(sector1, sector2, categorization: categorization)
        }
        return sector1.percentage ?? 0 > sector2.percentage ?? 0
    }
    
    private func calculatePercentages(of categories: [Category]) -> [Category] {
        let totalValue = categories.reduce(0) { $0 + ($1.amount.value ?? 0) }.doubleValue
        
        return categories.map {
            let relativeValue = (abs($0.amount.value?.doubleValue ?? 0.0)) / abs(totalValue) * 100
            return Category(type: $0.type,
                     percentage: relativeValue,
                     categorization: $0.categorization,
                     movements: $0.movements,
                     currency: $0.currency,
                     amount: $0.amount)
        }
        return categories
    }
    
    func calculateExpenseOrIncomeCategories(_ categories: [Category], categorization: AnalysisAreaCategorization) -> AnalysisAreaCategoriesRepresentable {
        var ordered = orderCategories(categories, categorization: categorization)
        var orderedCategories = ordered.categories
        var oppositeSignCategories = ordered.oppositeSignCategories
        var newCategories: [Category] = []
        var categoriesLowerThanTwelve: [Category] = []
        var categoriesInOthers: [Category] = []
        var othersTotal: Decimal = 0
        var othersPercentage: Double = 0
        
        for category in orderedCategories {
            if category.percentage < 12 {
                categoriesLowerThanTwelve.append(category)
                categoriesInOthers.append(category)
                othersTotal += category.amount.value ?? 0
                othersPercentage += category.percentage
            } else {
                newCategories.append(category)
            }
        }
        if categoriesLowerThanTwelve.count < 2 {
            return AnalysisAreaCategories(categoriesCategorization: categorization,
                                          newCategories: orderedCategories,
                                          oppositeSignCategories: oppositeSignCategories,
                                          others: [])
        }
        if newCategories.isEmpty {
            categoriesInOthers.removeFirst()
            newCategories.append(categoriesLowerThanTwelve.removeFirst())
            othersPercentage -= newCategories[0].percentage
            othersTotal -= newCategories[0].amount.value ?? 0
        }
        if othersPercentage > 50 {
            var categoriesLowerThanTen: [Category] = []
            othersPercentage = 0
            othersTotal = 0
            categoriesInOthers.removeAll()
            for category in categoriesLowerThanTwelve {
                if category.percentage < 10 {
                    categoriesInOthers.append(category)
                    categoriesLowerThanTen.append(category)
                    othersTotal += category.amount.value ?? 0
                    othersPercentage += category.percentage
                } else {
                    newCategories.append(category)
                }
            }
        }
        return AnalysisAreaCategories(categoriesCategorization: categorization,
                                      newCategories: newCategories,
                                      oppositeSignCategories: oppositeSignCategories,
                                      others: categoriesInOthers)
    }
    
    func orderCategories(_ categories: [Category], categorization: AnalysisAreaCategorization) -> (categories: [Category], oppositeSignCategories: [Category]) {
        var categoriesToOrder = [Category]()
        var oppositeSignCategories = [Category]()
        switch categorization {
        case .expenses, .payments:
            categoriesToOrder = categories.filter { ($0.amount.value ?? 0) < 0 }
            oppositeSignCategories = categories.filter { ($0.amount.value ?? 0) >= 0 }
        case .incomes:
            categoriesToOrder = categories.filter { ($0.amount.value ?? 0) > 0 }
            oppositeSignCategories = categories.filter { ($0.amount.value ?? 0) <= 0 }
        }
        categoriesToOrder = calculatePercentages(of: categoriesToOrder)
        return (categories: categoriesToOrder.sorted { compareCategories($0, $1, categorization: categorization) },
                oppositeSignCategories: oppositeSignCategories.sorted { compareCategories($0, $1, categorization: categorization) })
    }
}
