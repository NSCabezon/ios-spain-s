//
//  LoanHomeInternalDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 9/30/21.
//
import UI
import CoreFoundationLib
import Foundation

protocol LoanHomeDependenciesResolver {
    var external: LoanHomeExternalDependenciesResolver { get }
    func resolve() -> LoanHomeViewModel
    func resolve() -> LoanHomeViewController
    func resolve() -> LoanHomeCoordinator
    func resolve() -> SharedHandler
    func resolve() -> GetLoansUsecase
    func resolve() -> GetLoanTransactionsUsecase
    func resolve() -> DataBinding
}

extension LoanHomeDependenciesResolver {
    func resolve() -> LoanHomeViewModel {
        return LoanHomeViewModel(dependencies: self)
    }
    
    func resolve() -> LoanHomeViewController {
        return LoanHomeViewController(dependencies: self)
    }
    
    func resolve() -> SharedHandler {
        return SharedHandler()
    }
    
    func resolve() -> GetLoansUsecase {
        return DefaultGetLoansUsecase(dependencies: self)
    }
    
    func resolve() -> GetLoanTransactionsUsecase {
        return DefaultGetLoanTransactionsUsecase(dependencies: self)
    }
}
