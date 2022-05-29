//
//  LoanRepository.swift
//  SANServicesLibrary
//
//  Created by Juan Carlos López Robles on 10/28/21.
//
import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import SANLegacyLibrary
import CoreFoundationLib

public struct LoanReactiveDataRepository {
    private let loanManager: BSANLoansManager
    
    public init(loanManager: BSANLoansManager) {
        self.loanManager = loanManager
    }
}

extension LoanReactiveDataRepository: LoanReactiveRepository {
    
    public func loadDetail(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error> {
        guard let loanDTO = loan as? LoanDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<LoanDetailRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let result = try getLoanDetail(forLoan: loanDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func loadTransactions(loan: LoanRepresentable, page: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<LoanResultPageRepresentable, Error> {
        let paginationDTO = page as? PaginationDTO
        guard let loanDTO = loan as? LoanDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<LoanResultPageRepresentable, Error>{ promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let result = try getLoanTransactions(forLoan: loanDTO, dateFilter: nil, pagination: paginationDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func loadTransactionDetail(transaction: LoanTransactionRepresentable, loan: LoanRepresentable) -> AnyPublisher<LoanTransactionDetailRepresentable, Error> {
        guard let loanDTO = loan as? LoanDTO,
                let transactionDTO = transaction as? LoanTransactionDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<LoanTransactionDetailRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let result = try getLoanTransactionDetail(forLoan: loanDTO,
                                                              transaction: transactionDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

private extension LoanReactiveDataRepository {
    func getLoanDetail(forLoan loan: LoanDTO) throws -> LoanDetailRepresentable {
        let response = try loanManager.getLoanDetail(forLoan: loan)
        guard let result = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return result
    }
    
    func getLoanTransactions(forLoan loan: LoanDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> LoanResultPageRepresentable {
        let response = try loanManager.getLoanTransactions(forLoan: loan, dateFilter: nil, pagination: pagination)
        guard let responseData = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        let nextPage: PaginationDTO? = responseData.pagination.endList ? nil : responseData.pagination
        
        struct Result: LoanResultPageRepresentable {
            var transactions: [LoanTransactionRepresentable]
            var next: PaginationRepresentable?
        }
        
        return LoanResultPage(transactions: responseData.transactionDTOs, next: nextPage)
    }
    
    func getLoanTransactionDetail(forLoan loan: LoanDTO, transaction: LoanTransactionDTO) throws -> LoanTransactionDetailRepresentable {
        let response = try loanManager.getLoanTransactionDetail(forLoan: loan, loanTransaction: transaction)
        guard let responseData = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return responseData
    }
}

private extension LoanReactiveDataRepository {
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }

    struct LoanResultPage: LoanResultPageRepresentable {
        var transactions: [LoanTransactionRepresentable]
        var next: PaginationRepresentable?
    }
}
