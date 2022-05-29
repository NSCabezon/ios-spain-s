//
//  MockGetCardsExpensesCalculationUseCase.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 11/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib
import Cards

final class MockGetCardsExpensesCalculationUseCase: GetCardsExpensesCalculationUseCase {
    var mockExpensesCalled = false
    func fetchExpensesCalculationPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never> {
        mockExpensesCalled = true
        let expenses = AmountEntity(value: 0)
        return Just(expenses)
            .eraseToAnyPublisher()
    }
}
