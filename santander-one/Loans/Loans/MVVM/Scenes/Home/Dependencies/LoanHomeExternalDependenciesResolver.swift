//
//  LoanHomeExternalDependenciesResolver.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/1/21.
//
import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import OpenCombine

public protocol LoanHomeExternalDependenciesResolver: LoanCommonExternalDependenciesResolver, ShareDependenciesResolver, NavigationBarExternalDependenciesResolver {
    func resolve() -> LoanReactiveRepository
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> TimeManager
    func resolve() -> TrackerManager
    func resolve() -> LoansModifierProtocol?
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> GetLoanOptionsUsecase
    func loanHomeCoordinator() -> BindableCoordinator
    func loanDetailCoordinator() -> BindableCoordinator
    func loanTransactionsSearchCoordinator() -> BindableCoordinator
    func loanTransactionDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func globalSearchCoordinator() -> Coordinator
    func loanRepaymentCoordinator() -> BindableCoordinator
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator
    func loanCustomeOptionCoordinator() -> BindableCoordinator
}

public extension LoanHomeExternalDependenciesResolver {
    
    func resolve() -> LoansModifierProtocol? {
        return nil
    }
    
    func loanHomeCoordinator() -> BindableCoordinator {
        return DefaultLoanHomeCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func loanCustomeOptionCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolve() -> GetLoanOptionsUsecase {
        return DefaultGetLoanOptionsUsecase(dependencies: self)
    }
}
