//
//  FundsTransactionsFilterExternalDependenciesResolver.swift
//  Funds
//

import UI
import CoreFoundationLib
import CoreDomain

public protocol FundsTransactionsFilterExternalDependenciesResolver: NavigationBarExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func fundsTransactionsFilterCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func resolve() -> TrackerManager
    func resolve() -> StringLoader
    func resolve() -> FundsTransactionsFilterModifier?
}

extension FundsTransactionsFilterExternalDependenciesResolver {
    public func fundsTransactionsFilterCoordinator() -> BindableCoordinator {
        return DefaultFundsTransactionsFilterCoordinator(dependencies: self, navigationController: resolve())
    }

    public func resolve() -> FundsTransactionsFilterModifier? {
        nil
    }
}
