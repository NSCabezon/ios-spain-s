//
//  FundReactiveRepository.swift
//  CoreDomain
//
//  Created by Ernesto Fernandez Calles on 15/3/22.
//

import Foundation
import OpenCombine

public protocol FundReactiveRepository {
    func loadDetail(fund: FundRepresentable) -> AnyPublisher<FundDetailRepresentable, Error>
    func loadMovements(fund: FundRepresentable, pagination: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<FundMovementListRepresentable, Error>
    func loadMovementDetails(fund: FundRepresentable, movement: FundMovementRepresentable) -> AnyPublisher<FundMovementDetailRepresentable?, Error>
}
