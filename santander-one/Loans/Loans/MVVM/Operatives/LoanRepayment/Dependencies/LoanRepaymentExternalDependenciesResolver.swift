//
//  LoanRepaymentExternalDependenciesResolver.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/21/21.
//

import UI
import CoreFoundationLib
import Foundation

public protocol LoanRepaymentExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func loanRepaymentCoordinator() -> BindableCoordinator
}

public extension LoanRepaymentExternalDependenciesResolver {
    func loanRepaymentCoordinator() -> BindableCoordinator {
        return DefaultLoanRepaymentCoordinator(dependencies: self, navigationController: resolve())
    }
}
