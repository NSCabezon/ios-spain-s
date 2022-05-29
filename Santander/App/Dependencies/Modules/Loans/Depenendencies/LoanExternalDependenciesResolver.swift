//
//  LoanExternalDependenciesResolver.swift
//  Santander
//
//  Created by Juan Carlos López Robles on 1/20/22.
//

import UI
import Loans
import CoreFoundationLib
import CoreDomain
import Foundation
import RetailLegacy
import SantanderKey

extension ModuleDependencies: LoanExternalDependenciesResolver {
    
    func resolve() -> LoanReactiveRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> GetLoanTransactionDetailConfigurationUseCase {
        return SpainGetLoanTransactionDetailConfigurationUseCase()
    }
    
    func resolve() -> GetLoanTransactionDetailActionUseCase {
        return SpainGetLoanTransactionDetailConfigurationUseCase()
    }
    
    func resolve() -> GetLoanPDFInfoUseCase {
        return SpainGetLoanPDFInfoUseCase()
    }
}
