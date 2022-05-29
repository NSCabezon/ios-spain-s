//
//  GetExampleCardsExpensesCalculationUseCase.swift
//  Cards_Example
//
//  Created by Hernán Villamil on 14/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import OpenCombine
import CoreDomain
import Cards
import CoreFoundationLib

struct ExampleGetCardsExpensesCalculationUseCase {
    private let dependencies: DependenciesResolver
    private var pfmHelper: PfmHelperProtocol {
        dependencies.resolve(for: PfmHelperProtocol.self)
    }
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension ExampleGetCardsExpensesCalculationUseCase: GetCardsExpensesCalculationUseCase {
    func fetchExpensesCalculationPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never> {
        let expenses = pfmHelper.cardExpensesCalculationTransaction(userId: "", card: CardEntity(card))
        return Just(expenses)
            .eraseToAnyPublisher()
    }
}
