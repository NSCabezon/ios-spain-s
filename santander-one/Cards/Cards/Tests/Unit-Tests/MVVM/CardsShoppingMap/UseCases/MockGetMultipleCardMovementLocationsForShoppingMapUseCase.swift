//
//  MockGetMultipleCardMovementLocationsForShoppingMapUseCase.swift
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

struct MockGetMultipleCardMovementLocationsForShoppingMapUseCase{
    let repository: CardRepository
    init(injector: MockDataInjector) {
        self.repository = MockCardRepository(mockDataInjector: injector)
    }
}

extension MockGetMultipleCardMovementLocationsForShoppingMapUseCase : GetMultipleCardMovementLocationsForShoppingMapUseCase  {
    func fetchLocationsForShoppingMap(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return repository
            .loadCardTransactionLocationsList(card: card)
            .eraseToAnyPublisher()
    }
}
