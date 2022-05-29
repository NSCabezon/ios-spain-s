//
//  FundTransactionsDependenciesResolver.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 28/3/22.
//

import UI
import CoreFoundationLib

protocol FundTransactionsDependenciesResolver {
    var external: FundTransactionsExternalDependenciesResolver { get }
    func resolve() -> FundTransactionsViewModel
    func resolve() -> FundTransactionsViewController
    func resolve() -> FundTransactionsCoordinator
    func resolve() -> SharedHandler
    func resolve() -> DataBinding
    func resolve() -> GetFundMovementsUseCase
}

extension FundTransactionsDependenciesResolver {

    func resolve() -> FundTransactionsViewModel {
        return FundTransactionsViewModel(dependencies: self)
    }

    func resolve() -> FundTransactionsViewController {
        return FundTransactionsViewController(dependencies: self)
    }

    func resolve() -> GetFundMovementsUseCase {
        return DefaultGetFundMovementsUseCase(dependencies: self)
    }

    func resolve() -> SharedHandler {
        return SharedHandler()
    }
}

