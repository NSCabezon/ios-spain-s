//
//  CardTransactionFiltersDependenciesResolver.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol CardTransactionFiltersDependenciesResolver {
    var external: CardTransactionFiltersExternalDependenciesResolver { get }
    func resolve() -> CardTransactionFiltersCoordinator 
    func resolve() -> DataBinding
}

extension CardTransactionFiltersDependenciesResolver {
    
    func resolve() -> CardTransactionFiltersViewController {
        return CardTransactionFiltersViewController(dependencies: self)
    }
    
    func resolve() -> CardTransactionFiltersViewModel {
        return CardTransactionFiltersViewModel(dependencies: self)
    }
}
