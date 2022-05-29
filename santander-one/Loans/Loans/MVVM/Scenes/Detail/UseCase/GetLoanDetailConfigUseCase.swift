//
//  GetLoandUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 9/30/21.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetLoanDetailConfigUseCase {
    func fetchConfiguration() -> AnyPublisher<LoanDetailConfigRepresentable, Never>
}

struct DefaultGetLoanDetailConfigUseCase {
    private var dependencies: LoanDetailDependenciesResolver
    
    init(dependencies: LoanDetailDependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension DefaultGetLoanDetailConfigUseCase: GetLoanDetailConfigUseCase {
    func fetchConfiguration() -> AnyPublisher<LoanDetailConfigRepresentable, Never> {
        let configuration: LoanDetailConfigRepresentable = self.dependencies.external.resolve()
        return Just(configuration).eraseToAnyPublisher()
    }
}
