//
//  LoanTransactionsSearchDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/3/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol LoanTransactionSearchDependenciesResolver {
    var external: LoanTransactionSearchExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> LoanTransactionSearchViewController
    func resolve() -> LoanTransactionSearchViewModel
    func resolve() -> LoanTransactionSearchCoordinator
}

extension LoanTransactionSearchDependenciesResolver {
    func resolve() -> LoanTransactionSearchViewController {
        return LoanTransactionSearchViewController(dependencies: self)
    }
    
    func resolve() -> LoanTransactionSearchViewModel {
        return LoanTransactionSearchViewModel(dependencies: self)
    }
}
