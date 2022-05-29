//
//  GetAnalysisAreaCompaniesWithProductsUseCase.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 17/2/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetAnalysisAreaCompaniesWithProductsUseCase {
    func fechFinancialCompaniesPublisher() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error>
}

struct DefaultGetAnalysisAreaCompaniesWithProductsUseCase {
    private let repository: FinancialHealthRepository
    
    init(dependencies: AnalysisAreaCommonExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetAnalysisAreaCompaniesWithProductsUseCase: GetAnalysisAreaCompaniesWithProductsUseCase {
    func fechFinancialCompaniesPublisher() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error> {
        self.repository.getFinancialCompaniesWithProducts()
    }
}
