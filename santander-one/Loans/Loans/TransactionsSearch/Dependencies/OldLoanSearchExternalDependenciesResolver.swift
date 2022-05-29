//
//  LoanTransactionsSearchExternalDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/3/21.
//
import  UI
import Foundation
import CoreFoundationLib

public protocol OldLoanSearchExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func loanTransactionsSearchCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
}

extension OldLoanSearchExternalDependenciesResolver {
    public func loanTransactionsSearchCoordinator() -> BindableCoordinator {
        return OldDefaultLoanSearchCoordinator(dependencies: self, navigationController: resolve())
    }
}
