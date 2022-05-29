//
//  LoanTransactionsSearchExternalDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/3/21.
//
import  UI
import Foundation
import CoreFoundationLib
import CoreDomain

public protocol LoanTransactionSearchExternalDependenciesResolver: NavigationBarExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func loanTransactionsSearchCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func resolve() -> TrackerManager
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> StringLoader
    func resolve() -> GetLoanTransactionSearchConfigUseCase
}

extension LoanTransactionSearchExternalDependenciesResolver {
    public func loanTransactionsSearchCoordinator() -> BindableCoordinator {
        return DefaultLoanTransactionSearchCoordinator(dependencies: self, navigationController: resolve())
    }
    
    public func resolve() -> GetLoanTransactionSearchConfigUseCase {
        return DefaultGetLoanTransactionSearchConfigUseCase()
    }
}
