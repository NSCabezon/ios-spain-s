//
//  GetAnalysisAreaSummaryUseCase.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 16/2/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetAnalysisAreaSummaryUseCase {
    func fechFinancialSummaryPublisher(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error>
}

struct DefaultGetAnalysisAreaSummaryUseCase {
    private let repository: FinancialHealthRepository
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaSummaryUseCase: GetAnalysisAreaSummaryUseCase {
    func fechFinancialSummaryPublisher(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        self.repository.getFinancialSummary(products: products)
    }
}
