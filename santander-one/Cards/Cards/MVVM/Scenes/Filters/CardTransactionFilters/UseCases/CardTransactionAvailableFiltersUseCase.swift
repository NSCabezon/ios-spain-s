//
//  CardTransactionFiltersUseCase.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol CardTransactionAvailableFiltersUseCase {
    func fetchAvailableFiltersPublisher() -> AnyPublisher<CardTransactionAvailableFiltersRepresentable, Never>
}

struct DefaultCardTransactionAvailableFiltersUseCase {
    
    func fetchAvailableFiltersPublisher() -> AnyPublisher<CardTransactionAvailableFiltersRepresentable, Never> {
        return Just(DefaultCardTransactionFilters()).eraseToAnyPublisher()
    }
}

extension DefaultCardTransactionAvailableFiltersUseCase: CardTransactionAvailableFiltersUseCase {
    struct DefaultCardTransactionFilters: CardTransactionAvailableFiltersRepresentable {
        var byAmount: Bool = false
        var byExpenses: Bool = false
        var byTypeOfMovement: Bool = false
        var byConcept: Bool = false
    }
}
