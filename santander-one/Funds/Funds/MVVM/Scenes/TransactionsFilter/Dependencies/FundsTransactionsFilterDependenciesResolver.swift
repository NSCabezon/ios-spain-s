//
//  FundsTransactionsFilterDependenciesResolver.swift
//  Funds
//

import CoreFoundationLib
import UI

protocol FundsTransactionsFilterDependenciesResolver {
    var external: FundsTransactionsFilterExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> FundsTransactionsFilterViewController
    func resolve() -> FundsTransactionsFilterViewModel
    func resolve() -> FundsTransactionsFilterCoordinator
}

extension FundsTransactionsFilterDependenciesResolver {
    func resolve() -> FundsTransactionsFilterViewController {
        return FundsTransactionsFilterViewController(dependencies: self)
    }
    
    func resolve() -> FundsTransactionsFilterViewModel {
        return FundsTransactionsFilterViewModel(dependencies: self)
    }
}
