//
//  GetLoanDetailUsecase.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/11/21.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetLoanDetailUsecase {
    func fechDetailPublisher(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error>
}

struct DefaultGetLoanDetailUsecase {
    private let repository: LoanReactiveRepository
    
    init(dependencies: LoanCommonExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetLoanDetailUsecase: GetLoanDetailUsecase {
    func fechDetailPublisher(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error> {
        self.repository.loadDetail(loan: loan)
    }
}
