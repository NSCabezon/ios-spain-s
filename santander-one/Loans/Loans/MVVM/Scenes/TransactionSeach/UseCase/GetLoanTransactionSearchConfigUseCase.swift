//
//  GetLoandUseCase.swift
//  Pods
//
//  Created by Juan Jose Acosta on 15/3/21.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetLoanTransactionSearchConfigUseCase {
    func fetchConfiguration() -> AnyPublisher<LoanTransactionSearchConfigRepresentable, Never>
}

struct DefaultGetLoanTransactionSearchConfigUseCase: GetLoanTransactionSearchConfigUseCase {
    func fetchConfiguration() -> AnyPublisher<LoanTransactionSearchConfigRepresentable, Never> {
        return Just(DefaultLoanTransactionSearchConfig()).eraseToAnyPublisher()
    }
}

private extension DefaultGetLoanTransactionSearchConfigUseCase {
    struct DefaultLoanTransactionSearchConfig: LoanTransactionSearchConfigRepresentable {
        var isFiltersEnabled: Bool = true
        var isEnabledConceptFilter: Bool = true
        var isEnabledOperationTypeFilter: Bool = true
        var isEnabledAmountRangeFilter: Bool = true
        var isEnabledDateFilter: Bool = true
        var isDetailsCarouselEnabled: Bool = true
    }
}
