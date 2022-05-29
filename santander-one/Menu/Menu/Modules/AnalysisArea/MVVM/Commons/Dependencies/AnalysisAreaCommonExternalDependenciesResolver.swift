//
//  AnalysisAreaCommonExternalDependenciesResolver.swift
//  Account
//
//  Created by Miguel Bragado Sánchez on 21/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UI

public protocol AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> FinancialHealthRepository
    func resolve() -> GetAnalysisAreaCompaniesWithProductsUseCase
    func resolve() -> DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase
}

public extension AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> GetAnalysisAreaCompaniesWithProductsUseCase {
        DefaultGetAnalysisAreaCompaniesWithProductsUseCase(dependencies: self)
    }
    
    func resolve() -> DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
        DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase(dependencies: self)
    }
}
