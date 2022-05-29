//
//  GetCardsExpensesCalculationUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 14/1/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetCardsExpensesCalculationUseCase {
    func fetchExpensesCalculationPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never>
}

struct DefaultGetCardsExpensesCalculationUseCase: GetCardsExpensesCalculationUseCase {
    func fetchExpensesCalculationPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never> {
        let expenses = AmountEntity(value: 0)
        return Just(expenses)
            .eraseToAnyPublisher()
    }
}
