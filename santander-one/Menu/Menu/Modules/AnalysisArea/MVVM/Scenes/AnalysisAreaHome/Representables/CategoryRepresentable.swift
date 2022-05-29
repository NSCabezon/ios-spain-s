//
//  CategoryRepresentable.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 2/3/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol CategoryRepresentable {
    var type: AnalysisAreaCategoryType { get }
    var percentage: Double { get }
    var categorization: AnalysisAreaCategorization { get }
    var movements: Int { get }
    var currency: CurrencyRepresentable { get }
    var amount: AmountEntity { get }
}

protocol AnalysisAreaCategoriesRepresentable {
    var nonOtherCategories: [CategoryRepresentable] { get }
    var otherCategories: [CategoryRepresentable] { get }
    var totalCategoriesAmount: Decimal { get }
    var totalOthersCategoriesAmount: Decimal { get }
    var othersAsCategory: CategoryRepresentable? { get }
    var categorization: AnalysisAreaCategorization { get }
    var chartCategories: [CategoryRepresentable] { get }
    var listCategories: [CategoryRepresentable] { get }
    var oppositeSignCategoriesCount: Int { get }
}

struct AnalysisAreaCategories {
    let categoriesCategorization: AnalysisAreaCategorization
    let newCategories: [Category]
    let oppositeSignCategories: [Category]
    let others: [Category]
}

extension AnalysisAreaCategories: AnalysisAreaCategoriesRepresentable {
    var chartCategories: [CategoryRepresentable] {
        var allCategories = [CategoryRepresentable]()
        allCategories.append(contentsOf: newCategories)
        guard let othersCategory = othersAsCategory else { return allCategories }
        allCategories.append(othersCategory)
        return allCategories
    }
    
    var listCategories: [CategoryRepresentable] {
        var list = [CategoryRepresentable]()
        list.append(contentsOf: newCategories)
        guard let othersCategory = othersAsCategory else {
            list.append(contentsOf: oppositeSignCategories)
            return list
        }
        list.append(othersCategory)
        return list
    }
    
    var categorization: AnalysisAreaCategorization {
        categoriesCategorization
    }
    
    var nonOtherCategories: [CategoryRepresentable] {
        newCategories
    }
    
    var otherCategories: [CategoryRepresentable] {
        var othersCategoriesArray = others
        if !others.isEmpty, !oppositeSignCategories.isEmpty {
            othersCategoriesArray.append(contentsOf: oppositeSignCategories)
        }
        return othersCategoriesArray
    }
    
    var totalCategoriesAmount: Decimal {
        return newCategories.reduce(0) { $0 + ($1.amount.value ?? 0) }
    }
    
    var totalOthersCategoriesAmount: Decimal {
        return others.compactMap { $0.amount.value }.reduce(0, +)
    }
    
    var othersAsCategory: CategoryRepresentable? {
        guard !others.isEmpty else { return nil }
        let totalPercentage = others.reduce(0) { $0 + $1.percentage }
        let totalMovements = others.reduce(0) { $0 + $1.movements }
        let othersCurrency = others.first?.currency ?? CurrencyRepresented(currencyCode: "EUR")
        let othersAmountValue: Decimal = others.reduce(0.0) { $0 + ($1.amount.value ?? 0.0) }
        return Category(type: .otherExpenses,
                        percentage: Double(totalPercentage),
                        categorization: self.categorization,
                        movements: totalMovements,
                        currency: othersCurrency,
                        amount: AmountEntity(value: othersAmountValue,
                                             currency: othersCurrency.currencyType)
        )
    }
    
    var oppositeSignCategoriesCount: Int {
        return oppositeSignCategories.count
    }
}

struct Category {
    private let summaryItemRepresentable: FinancialHealthSummaryItemRepresentable?
    private let categoryType: AnalysisAreaCategoryType?
    private let categoryPercentage: Double
    private let categoryCategorization: AnalysisAreaCategorization?
    private let categoryMovements: Int?
    private let categoryCurrency: CurrencyRepresentable?
    private let categoryAmount: AmountEntity?
    
    init(representable: AnalysisAreaSummaryItemRepresentable, type: AnalysisAreaCategoryType? = nil,percentage: Double? = nil ,categorization: AnalysisAreaCategorization? = nil, movements: Int? = nil,
         currency: CurrencyRepresentable? = nil, amount: AmountEntity? = nil) {
        self.summaryItemRepresentable = representable
        self.categoryType = type
        self.categoryPercentage = percentage ?? 0.0
        self.categoryCategorization = categorization
        self.categoryMovements = movements
        self.categoryCurrency = currency
        self.categoryAmount = amount
    }
    
    init(representable: AnalysisAreaSummaryItemRepresentable? = nil, type: AnalysisAreaCategoryType,percentage: Double ,categorization: AnalysisAreaCategorization ,movements: Int ,currency: CurrencyRepresentable ,amount: AmountEntity) {
        self.summaryItemRepresentable = representable
        self.categoryType = type
        self.categoryPercentage = percentage
        self.categoryCategorization = categorization
        self.categoryMovements = movements
        self.categoryCurrency = currency
        self.categoryAmount = amount
    }
}

extension Category: CategoryRepresentable {
    
    var type: AnalysisAreaCategoryType {
        let defaultType: AnalysisAreaCategoryType = .otherExpenses
        guard let representable = summaryItemRepresentable else {
            if let type = categoryType { return type }
            return defaultType
        }
        return AnalysisAreaCategoryType(representable.code) ?? defaultType
    }
    
    var percentage: Double {
        guard let representable = summaryItemRepresentable else {
           return categoryPercentage
        }
        return Double(representable.percentage ?? 0)
    }
    
    var categorization: AnalysisAreaCategorization {
        let defaultCategorization: AnalysisAreaCategorization = .expenses
        guard let representable = summaryItemRepresentable else {
            if let categorization = categoryCategorization { return categorization }
            return defaultCategorization
        }
        return AnalysisAreaCategorization(rawValue: representable.type ?? 0) ?? defaultCategorization
    }
    
    var movements: Int {
        guard let representable = summaryItemRepresentable else {
            if let movements = categoryMovements { return movements }
            return 0
        }
        return representable.transactions ?? 0
    }
    
    var currency: CurrencyRepresentable {
        guard let representable = summaryItemRepresentable else {
            if let currency = categoryCurrency { return currency }
            return CurrencyRepresented(currencyCode: "EUR")
        }
       return CurrencyRepresented(currencyCode: representable.currency ?? "EUR")
    }
    
    var amount: AmountEntity {
        guard let representable = summaryItemRepresentable else {
            if let amount = categoryAmount { return amount }
            return AmountEntity(value: 0.0, currency: currency.currencyType)
        }
        return AmountEntity(value: Decimal(representable.total ?? 0.0), currency: currency.currencyType)
    }
}
