//
//  GetDatedCardmovementsLocationsForShoppingMapUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetDatedCardMovementsLocationsForShoppingMapUseCase {
    func fetchLocationsForShoppingMap(card: CardRepresentable,
                                      startDate: Date,
                                      endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never>
}

struct DefaultGetDatedCardMovementsLocationsUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardShoppingMapExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetDatedCardMovementsLocationsUseCase: GetDatedCardMovementsLocationsForShoppingMapUseCase {
    func fetchLocationsForShoppingMap(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return repository
            .loadCardTransactionLocationsListByDate(card: card,
                                                    startDate: startDate,
                                                    endDate: endDate)
            .eraseToAnyPublisher()
    }
}
