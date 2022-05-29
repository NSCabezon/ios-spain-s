//
//  GetLoandUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 9/30/21.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetLoansUsecase {
    func fechLoans() -> AnyPublisher<[LoanRepresentable], Never>
}

struct DefaultGetLoansUsecase {
    private var repository: GlobalPositionDataRepository
    
    init(dependencies: LoanHomeDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetLoansUsecase: GetLoansUsecase {
    func fechLoans() -> AnyPublisher<[LoanRepresentable], Never> {
        return repository.getGlobalPosition()
            .map(\.loanRepresentables)
            .eraseToAnyPublisher()
    }
}
