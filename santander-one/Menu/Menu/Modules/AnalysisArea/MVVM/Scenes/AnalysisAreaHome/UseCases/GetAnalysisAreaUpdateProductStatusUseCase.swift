//
//  GetAnalysisAreaUpdateProductStatusUseCase.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 2/3/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetAnalysisAreaUpdateProductStatusUseCase {
    func fechFinancialUpdateProductStatusPublisher(productCode: String) -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error>
}

struct DefaultGetAnalysisAreaUpdateProductStatusUseCase {
    private let repository: FinancialHealthRepository
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaUpdateProductStatusUseCase: GetAnalysisAreaUpdateProductStatusUseCase {
    func fechFinancialUpdateProductStatusPublisher(productCode: String) -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        self.repository.getFinancialUpdateProductStatus(productCode: productCode)
    }
}
