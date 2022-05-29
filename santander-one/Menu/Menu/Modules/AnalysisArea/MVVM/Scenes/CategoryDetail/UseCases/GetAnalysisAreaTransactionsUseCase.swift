//
//  GetAnalysisAreaTransactionsUseCase.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 5/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetAnalysisAreaTransactionsUseCase {
    func fetchFinancialTransactionsPublisher(category: GetFinancialHealthTransactionsInputRepresentable) -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Error>
}

struct DefaultGetAnalysisAreaTransactionsUseCase {
    private let repository: FinancialHealthRepository

    init(dependencies: AnalysisAreaCategoryDetailDependenciesResolver) {
        repository = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaTransactionsUseCase: GetAnalysisAreaTransactionsUseCase {
    func fetchFinancialTransactionsPublisher(category: GetFinancialHealthTransactionsInputRepresentable) -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Error> {
        self.repository.getFinancialtransactions(category: category)
    }
}

struct TransactionsInput: GetFinancialHealthTransactionsInputRepresentable {
    var dateFrom: Date
    var dateTo: Date
    var page: String
    var scale: TimeViewOptions
    var category: AnalysisAreaCategoryType
    var subCategory: [FinancialHealthSubcategoryType]
    var type: AnalysisAreaCategorization
    var rangeFrom: Int?
    var rangeTo: Int?
    var text: String?
    var products: [GetFinancialHealthCategoryProductInputRepresentable]
}
