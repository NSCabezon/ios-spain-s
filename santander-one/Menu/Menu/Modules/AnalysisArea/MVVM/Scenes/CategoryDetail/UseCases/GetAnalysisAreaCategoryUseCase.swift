//
//  GetAnalysisAreaCategoryUseCase.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 1/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetAnalysisAreaCategoryDetailInfoUseCase {
    func fetchFinancialCategoryPublisher(categories: GetFinancialHealthCategoryInputRepresentable) -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Error>
}

struct DefaultGetAnalysisAreaCategoryUseCase {
    private let repository: FinancialHealthRepository

    init(dependencies: AnalysisAreaCategoryDetailDependenciesResolver) {
        repository = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaCategoryUseCase: GetAnalysisAreaCategoryDetailInfoUseCase {

    func fetchFinancialCategoryPublisher(categories: GetFinancialHealthCategoryInputRepresentable) -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Error> {
        return self.repository.getFinancialCategoryDetailInfo(categories: categories)
    }
}

struct GetCategoryDetailInfoInput: GetFinancialHealthCategoryInputRepresentable {
    var dateFrom: Date?
    var dateTo: Date?
    var scale: TimeViewOptions
    var category: AnalysisAreaCategoryType
    var subcategory: [FinancialHealthSubcategoryType]
    var type: AnalysisAreaCategorization
    var rangeFrom: Int?
    var rangeTo: Int?
    var text: String?
    var products: [GetFinancialHealthCategoryProductInputRepresentable]?
}

struct GetCategoryDetailInfoProductInput: GetFinancialHealthCategoryProductInputRepresentable {
    var productType: String?
    var productId: String?
}
