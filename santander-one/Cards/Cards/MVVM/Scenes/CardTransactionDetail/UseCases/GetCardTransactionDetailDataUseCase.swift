//
//  GetCardTransactionDetailDataUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 20/4/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetCardTransactionDetailDataUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable,
                                    transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailRepresentable, Error>
}

struct DefaultGetCardTransactionDetailDataUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetCardTransactionDetailDataUseCase: GetCardTransactionDetailDataUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailRepresentable, Error> {
        return repository
            .loadCardTransactionDetail(card: card,
                                       transaction: transaction)
            .eraseToAnyPublisher()
    }
}
