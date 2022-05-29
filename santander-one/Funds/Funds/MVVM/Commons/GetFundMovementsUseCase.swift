//
//  GetFundMovementsUseCase.swift
//  Funds
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetFundMovementsUseCase {
    func fechMovementsPublisher(fund: FundRepresentable, pagination: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<FundMovementListRepresentable, Error>
    func fechMovementDetailsPublisher(fund: FundRepresentable, movement: FundMovementRepresentable) -> AnyPublisher<FundMovementDetailRepresentable?, Error>
}

struct DefaultGetFundMovementsUseCase {
    private let repository: FundReactiveRepository

    init(dependencies: FundsHomeDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }

    init(dependencies: FundTransactionsDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetFundMovementsUseCase: GetFundMovementsUseCase {
    func fechMovementsPublisher(fund: FundRepresentable, pagination: PaginationRepresentable?, filters: TransactionFiltersRepresentable?) -> AnyPublisher<FundMovementListRepresentable, Error> {
        self.repository.loadMovements(fund: fund, pagination: pagination, filters: filters)
    }

    func fechMovementDetailsPublisher(fund: FundRepresentable, movement: FundMovementRepresentable) -> AnyPublisher<FundMovementDetailRepresentable?, Error> {
        self.repository.loadMovementDetails(fund: fund, movement: movement)
    }
}
