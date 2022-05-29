//
//  GetLoanTransactionsUsecase.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/19/21.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetLoanTransactionsUsecase {
    func loadTransactionsPublisher(loan: LoanRepresentable, page: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<LoanResultPageRepresentable, Error>
}

struct DefaultGetLoanTransactionsUsecase {
    private let repository: LoanReactiveRepository
    
    init(dependencies: LoanHomeDependenciesResolver) {
        repository = dependencies.external.resolve()
    }
}

extension DefaultGetLoanTransactionsUsecase: GetLoanTransactionsUsecase {
    func loadTransactionsPublisher(loan: LoanRepresentable, page: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<LoanResultPageRepresentable, Error> {
        return repository
            .loadTransactions(loan: loan, page: page, filters: filters)
            .eraseToAnyPublisher()
    }
}
