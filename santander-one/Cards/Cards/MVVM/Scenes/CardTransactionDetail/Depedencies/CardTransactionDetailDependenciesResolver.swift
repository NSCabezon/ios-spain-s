//
//  CardTransactionDetailDependenciesResolver.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

protocol CardTransactionDetailDependenciesResolver {
    var external: CardTransactionDetailExternalDependenciesResolver { get }
    func resolve() -> CardTransactionDetailViewController
    func resolve() -> CardTransactionDetailViewModel
    func resolve() -> DataBinding
    func cardTransactionDetailCoordinator() -> CardTransactionDetailCoordinator
}

extension CardTransactionDetailDependenciesResolver {
    func resolve() -> CardTransactionDetailViewController {
        return CardTransactionDetailViewController(dependencies: self)
    }
    func resolve() -> CardTransactionDetailViewModel {
        return CardTransactionDetailViewModel(dependencies: self)
    }
}
