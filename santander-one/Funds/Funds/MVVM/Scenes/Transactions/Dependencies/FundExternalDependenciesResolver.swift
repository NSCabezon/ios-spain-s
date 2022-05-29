//
//  FundTransactionsExternalDependenciesResolver.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 28/3/22.
//

import UI
import CoreDomain
import CoreFoundationLib

public protocol FundTransactionsExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver {
    var common: FundsCommonExternalDependenciesResolver { get }
    func fundTransactionsCoordinator() -> BindableCoordinator
    func fundsTransactionsFilterCoordinator() -> BindableCoordinator
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> TrackerManager
    func resolve() -> FundReactiveRepository
    func resolve() -> StringLoader
}

public extension FundTransactionsExternalDependenciesResolver {

    func fundTransactionsCoordinator() -> BindableCoordinator {
        return DefaultFundTransactionsCoordinator(dependencies: self, navigationController: resolve())
    }
}
