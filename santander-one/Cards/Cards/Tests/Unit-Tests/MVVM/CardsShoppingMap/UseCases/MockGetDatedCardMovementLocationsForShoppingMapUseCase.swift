//
//  MockGetDatedCardMovementLocationsForShoppingMapUseCase.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import Foundation
import CoreDomain
import OpenCombine
import CoreTestData
import SANLegacyLibrary
@testable import Cards

struct MockGetDatedCardMovementLocationsForShoppingMapUseCase{
    let repository: CardRepository
    init(injector: MockDataInjector) {
        self.repository = MockCardRepository(mockDataInjector: injector)
    }
}

extension MockGetDatedCardMovementLocationsForShoppingMapUseCase : GetDatedCardMovementsLocationsForShoppingMapUseCase  {
    func fetchLocationsForShoppingMap(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return repository
            .loadCardTransactionLocationsListByDate(card: card,
                                                    startDate: startDate,
                                                    endDate: endDate)
            .eraseToAnyPublisher()
    }
}
