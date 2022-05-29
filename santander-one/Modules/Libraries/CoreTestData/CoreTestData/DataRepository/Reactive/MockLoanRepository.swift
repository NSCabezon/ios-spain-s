//
//  LoanRepositoryMock.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/19/21.
//

import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import CoreFoundationLib

public final class MockLoanRepository: LoanReactiveRepository {
    var detail: LoanDetailRepresentable
    var transactions: [LoanTransactionRepresentable]
    var transactionDetail: LoanTransactionDetailRepresentable
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
    
    public init(mockDataInjector: MockDataInjector) {
        detail = mockDataInjector
            .mockDataProvider
            .loansData
            .getLoanDetail
        
        transactions = mockDataInjector
            .mockDataProvider
            .loansData
            .getLoanTransactions
            .transactionDTOs
        
        transactionDetail = mockDataInjector
            .mockDataProvider
            .loansData
            .getLoanTransactionDetail
    }
    
    public func loadDetail(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error> {
        guard loan.productIdentifier != "fail" else {
            return Fail(error: SomeError()).eraseToAnyPublisher()
        }
        return Just(detail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadTransactions(loan: LoanRepresentable, page: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<LoanResultPageRepresentable, Error> {
        guard loan.productIdentifier != "fail" else {
            return Fail(error: SomeError(errorDescription: "generic_label_emptyNotAvailableMoves")).eraseToAnyPublisher()
        }
        let nextPage = loan.productIdentifier == "pagining" ? NextPage() : nil
        return Just(ResultPage(transactions: transactions, next: nextPage))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadTransactionDetail(transaction: LoanTransactionRepresentable, loan: LoanRepresentable) -> AnyPublisher<LoanTransactionDetailRepresentable, Error> {
        return Just(transactionDetail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct ResultPage: LoanResultPageRepresentable {
    var transactions: [LoanTransactionRepresentable]
    var next: PaginationRepresentable?
}

struct NextPage: PaginationRepresentable {}
