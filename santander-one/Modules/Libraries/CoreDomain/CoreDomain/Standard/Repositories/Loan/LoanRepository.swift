//
//  LoanRepository.swift
//  CoreDomain
//
//  Created by Juan Carlos López Robles on 10/4/21.
//

import Foundation
import OpenCombine

public protocol LoanReactiveRepository {
    func loadDetail(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error>
    func loadTransactions(loan: LoanRepresentable, page: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<LoanResultPageRepresentable, Error>
    func loadTransactionDetail(transaction: LoanTransactionRepresentable, loan: LoanRepresentable) -> AnyPublisher<LoanTransactionDetailRepresentable, Error>
}
