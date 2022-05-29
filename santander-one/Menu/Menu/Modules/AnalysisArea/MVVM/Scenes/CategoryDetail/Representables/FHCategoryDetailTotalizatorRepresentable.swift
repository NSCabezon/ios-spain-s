//
//  FHCategoryDetailTotalizatorRepresentable.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 12/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

protocol FHCategoryDetailTotalizatorRepresentable {
    var categoryName: String { get }
    var categoryIcon: String { get }
    var categorization: AnalysisAreaCategorization { get }
    var periodSelected: PeriodSelectorRepresentable? { get }
    var currency: String? { get }
    var subcategories: [GetFinancialHealthSubcategoryRepresentable] { get }
}

struct TotalizatorAndSubcategoriesRepresented: FHCategoryDetailTotalizatorRepresentable {
    var categoryName: String
    var categoryIcon: String
    var categorization: AnalysisAreaCategorization
    var periodSelected: PeriodSelectorRepresentable?
    var currency: String?
    var subcategories: [GetFinancialHealthSubcategoryRepresentable]
}
