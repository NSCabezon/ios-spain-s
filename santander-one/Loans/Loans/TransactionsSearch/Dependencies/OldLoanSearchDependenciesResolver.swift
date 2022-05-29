//
//  LoanTransactionsSearchDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/3/21.
//

import Foundation
import CoreFoundationLib

protocol OldLoanSearchDependenciesResolver {
    var external: OldLoanSearchExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
