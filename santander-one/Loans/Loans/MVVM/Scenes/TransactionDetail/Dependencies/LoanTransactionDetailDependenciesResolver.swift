//
//  LoanTransactionDependenciesResolver.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/25/21.
//
import CoreFoundationLib
import Foundation

protocol LoanTransactionDetailDependenciesResolver: CoreDependenciesResolver {
    var external: LoanTransactionDetailExternalDependenciesResolver { get }
    func resolve() -> LoanTransactionDetailViewModel
    func resolve() -> DataBinding
    func resolve() -> LoanTransactionDetailViewController
    func resolve() -> LoanTransactionDetailCoordinator
    func resolve() -> GetLoanTransactionDetailUseCase
}

extension LoanTransactionDetailDependenciesResolver {
    func resolve() -> LoanTransactionDetailViewController {
        return LoanTransactionDetailViewController(dependencies: self)
    }
    
    func resolve() -> LoanTransactionDetailViewModel {
        return LoanTransactionDetailViewModel(dependencies: self)
    }
    
    func resolve() -> GetLoanTransactionDetailUseCase {
        return asShared {
            DefaultGetLoanTransactionDetailUseCase(dependencies: self)
        }
    }
}
