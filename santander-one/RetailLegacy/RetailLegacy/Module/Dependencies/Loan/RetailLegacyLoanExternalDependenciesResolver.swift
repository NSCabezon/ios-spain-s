//
//  RetailLegacyLoanExternalDependenciesResolver.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/16/21.
//

import UI
import CoreFoundationLib
import Foundation

public protocol RetailLegacyLoanExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func loanHomeCoordinator() -> BindableCoordinator
    func loanRepaymentCoordinator() -> BindableCoordinator
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator
    func loanTransactionDetailActionsCoordinator() -> BindableCoordinator
}

public extension RetailLegacyLoanExternalDependenciesResolver {
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator {
        return LoanChangeLinkedAccountCoordinator(dependencies: self)
    }
    
    func loanTransactionDetailActionsCoordinator() -> BindableCoordinator {
        return LoanTransactionDetailActionsCoordinator(dependencies: self)
    }
}
