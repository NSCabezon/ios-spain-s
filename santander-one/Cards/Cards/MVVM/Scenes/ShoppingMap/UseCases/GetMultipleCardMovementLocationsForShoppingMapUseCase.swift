//
//  GetMultipleCardMovementLocationsForShoppingMapUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetMultipleCardMovementLocationsForShoppingMapUseCase {
    func fetchLocationsForShoppingMap(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never>
}

struct DefaultGetMultipleCardMovementLocationsUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardShoppingMapExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetMultipleCardMovementLocationsUseCase: GetMultipleCardMovementLocationsForShoppingMapUseCase {
    func fetchLocationsForShoppingMap(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return repository
            .loadCardTransactionLocationsList(card: card)
            .eraseToAnyPublisher()
    }
}
