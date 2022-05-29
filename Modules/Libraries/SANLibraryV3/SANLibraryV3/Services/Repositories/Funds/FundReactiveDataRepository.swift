//
//  FundReactiveDataRepository.swift
//  SANLibraryV3
//
//  Created by Ernesto Fernandez Calles on 24/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import SANLegacyLibrary
import CoreFoundationLib

public struct FundReactiveDataRepository {
    private let fundManager: BSANFundsManager

    public init(fundManager: BSANFundsManager) {
        self.fundManager = fundManager
    }
}

extension FundReactiveDataRepository: FundReactiveRepository {

    public func loadDetail(fund: FundRepresentable) -> AnyPublisher<FundDetailRepresentable, Error> {
        guard let fundDTO = fund as? FundDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<FundDetailRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let result = try getFundDetail(forFund: fundDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func loadMovements(fund: FundRepresentable, pagination: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<FundMovementListRepresentable, Error> {
        guard let fundDTO = fund as? FundDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<FundMovementListRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    var dateFilter: DateFilter?
                    if let dateIntervalFilter = filters?.dateInterval {
                        dateFilter = DateFilter(from: dateIntervalFilter.start, to: dateIntervalFilter.end)
                    }
                    let pagination = pagination as? PaginationDTO
                    let result = try getFundMovements(forFund: fundDTO, withFilter: dateFilter, andPagination: pagination)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func loadMovementDetails(fund: FundRepresentable, movement: FundMovementRepresentable) -> AnyPublisher<FundMovementDetailRepresentable?, Error> {
        guard let fundDTO = fund as? FundDTO, let transactionDTO = movement as? FundTransactionDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<FundMovementDetailRepresentable?, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let result = try getFundMovementDetail(for: fundDTO, transaction: transactionDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

private extension FundReactiveDataRepository {
    func getFundDetail(forFund fund: FundDTO) throws -> FundDetailRepresentable {
        let response = try fundManager.getFundDetail(forFund: fund)
        guard let result = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return result
    }

    func getFundMovements(forFund fund: FundDTO, withFilter filter: DateFilter?, andPagination pagination : PaginationDTO?) throws -> FundMovementListRepresentable {
        let response = try fundManager.getFundTransactions(forFund: fund, dateFilter: filter, pagination: pagination)
        guard let result = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return result
    }

    func getFundMovementDetail(for fund: FundDTO, transaction: FundTransactionDTO) throws -> FundMovementDetailRepresentable {
        let response = try fundManager.getFundTransactionDetail(forFund: fund, fundTransactionDTO: transaction)
        guard let result = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return result
    }
}

private extension FundReactiveDataRepository {
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
}
