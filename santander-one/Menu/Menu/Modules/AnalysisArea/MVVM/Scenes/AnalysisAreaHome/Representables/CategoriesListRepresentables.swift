//
//  CategoriesListRepresentables.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 2/3/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

// MARK: Category View
struct CategoryViewRepresented {
    let categoryData: CategoryRepresentable
}

extension CategoryViewRepresented: CategoryViewRepresentable {
    var titleKey: String {
        categoryData.type.literalKey
    }
    
    var titleText: String {
        return localized(categoryData.type.literalKey)
    }
    
    var movementsText: String {
        let percentage: String = categoryData.percentage == 0.0 ? "0" : "\(Double(categoryData.percentage).asFinancialAgregatorPercentText(includePercentSimbol: false))"
        let percentageText = localized("generic_label_percentageParentheses", [StringPlaceholder(.number, percentage)]).text
        guard categoryData.movements > 1 else {
            return localized("analysis_label_movement", [StringPlaceholder(.number, "\(categoryData.movements)")]).text + " \(percentageText)"
        }
        return localized("analysis_label_movement_other", [StringPlaceholder(.number, "\(categoryData.movements)")]).text + " \(percentageText)"
    }
    
    var amount: AmountEntity {
        return categoryData.amount
    }
    
    var imageKey: String {
        return categoryData.type.iconKey
    }
    
    var categorization: AnalysisAreaCategorization {
        return categoryData.categorization
    }
    
    var totalMovements: Int {
        categoryData.movements
    }
    
    var totalPercentage: Double {
        categoryData.percentage
    }
}

// MARK: Other Expenses
struct OtherExpensesViewRepresented {
    let otherCategories: [CategoryRepresentable]
    
    private var computableOthers: [CategoryRepresentable] {
        otherCategories.filter { categorization != .incomes ? ($0.amount.value ?? 0 < 0) : ($0.amount.value ?? 0 >= 0) }
    }
}

extension OtherExpensesViewRepresented: OtherExpensesViewRepresentable {
    
    var categories: [CategoryRepresentable] {
        return otherCategories
    }
    
    var titleText: String {
        switch categorization {
        case .expenses:
            return localized("categorization_label_otherExpensesEllipsis")
        case .payments:
            return localized("categorization_label_otherPaymentsEllipsis")
        case .incomes:
            return localized("categorization_label_otherIncomeEllipsis")
        }
    }
    
    var titleKey: String {
        "categorization_label_otherExpensesEllipsis"
    }
    
    var movementsText: String {
        let totalPercentage = computableOthers.reduce(0) { $0 + $1.percentage }
        let totalMovements = computableOthers.reduce(0) { $0 + $1.movements }
        let percentageText = localized("generic_label_percentageParentheses", [StringPlaceholder(.number, "\(totalPercentage.asFinancialAgregatorPercentText(includePercentSimbol: false))")]).text
        guard totalMovements > 1 else {
            return localized("analysis_label_movement", [StringPlaceholder(.number, "\(totalMovements)")]).text + " \(percentageText)"
        }
        return localized("analysis_label_movement_other", [StringPlaceholder(.number, "\(totalMovements)")]).text + " \(percentageText)"
    }
    
    var amount: AmountEntity {
        let total = computableOthers.compactMap { $0.amount.value }.reduce(0.0, +)
        return AmountEntity(value: total, currency: categories.first?.currency.currencyType ?? .eur)
    }
    
    var imageKey: String {
        "oneIcnArrowRoundedDown"
    }
    
    var expandedImageKey: String {
        "oneIcnArrowRoundedUp"
    }
    
    var categorization: AnalysisAreaCategorization {
        otherCategories.first?.categorization ?? .expenses
    }
    
    var totalMovements: Int {
        computableOthers.reduce(0) { $0 + $1.movements }
    }
    
    var totalPercentage: Double {
        computableOthers.reduce(0) { $0 + $1.percentage }
    }
}
