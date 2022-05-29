 //
//  CardTransactionFilterValidator.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 20/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import UIKit
import UI
import CoreFoundationLib

/// Use this protocol to modify or perform any action when Core is going to save the given card filters. For example, you can show an alert and return a publisher with a filtered array of the given card filters.
public protocol CardTransactionFilterValidator {
    func fetchFiltersPublisher(given filters: [CardTransactionFilterType], card: CardRepresentable) -> AnyPublisher<[CardTransactionFilterType], Never>
}

struct DefaultCardTransactionFilterValidator: CardTransactionFilterValidator {
    
    let dependencies: CardTransactionFiltersExternalDependenciesResolver
    
    func fetchFiltersPublisher(given filters: [CardTransactionFilterType], card: CardRepresentable) -> AnyPublisher<[CardTransactionFilterType], Never> {
        return Just(filters).eraseToAnyPublisher()
    }
}
