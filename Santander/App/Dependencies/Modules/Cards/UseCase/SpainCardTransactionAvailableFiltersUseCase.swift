//
//  SpainCardTransactionAvailableFiltersUseCase.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 28/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import Cards

struct SpainCardTransactionAvailableFiltersUseCase {
    
    func fetchAvailableFiltersPublisher() -> AnyPublisher<CardTransactionAvailableFiltersRepresentable, Never> {
        return Just(SpainCardTransactionFilters()).eraseToAnyPublisher()
    }
}

extension SpainCardTransactionAvailableFiltersUseCase: CardTransactionAvailableFiltersUseCase {
    struct SpainCardTransactionFilters: CardTransactionAvailableFiltersRepresentable {
        var byAmount: Bool = false
        var byExpenses: Bool = false
        var byTypeOfMovement: Bool = true
        var byConcept: Bool = true
    }
}
