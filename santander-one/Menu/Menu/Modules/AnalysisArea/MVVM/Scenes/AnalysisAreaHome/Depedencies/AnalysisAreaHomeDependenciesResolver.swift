//
//  AnalysisAreaHomeDependenciesResolver.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

 import UI
 import Foundation
 import OpenCombine
 import CoreDomain
import CoreFoundationLib
 
protocol AnalysisAreaHomeDependenciesResolver {
    var external: AnalysisAreaHomeExternalDependenciesResolver { get }
    func resolve() -> AnalysisAreaViewModel
    func resolve() -> AnalysisAreaViewController
    func resolve() -> AnalysisAreaCoordinator
    func resolve() -> DataBinding
    func resolve() -> GetAnalysisAreaSummaryUseCase
    func resolve() -> ManagePeriodSelectedAnalysisAreaUseCase
    func resolve() -> GetAnalysisAreaUpdateProductStatusUseCase
    func resolve() -> GetAnalysisAreaOffersUseCase
}

extension AnalysisAreaHomeDependenciesResolver {
    
    func resolve() -> AnalysisAreaViewModel {
        return AnalysisAreaViewModel(dependencies: self)
    }
    
    func resolve() -> AnalysisAreaViewController {
        return AnalysisAreaViewController(dependencies: self)
    }
    
    func resolve() -> GetAnalysisAreaSummaryUseCase {
        return DefaultGetAnalysisAreaSummaryUseCase(dependencies: self)
    }
    
    func resolve() -> ManagePeriodSelectedAnalysisAreaUseCase {
        return DefaultManagePeriodSelectedAnalysisAreaUseCase(dependencies: self)
    }
    
    func resolve() -> GetAnalysisAreaUpdateProductStatusUseCase {
        return DefaultGetAnalysisAreaUpdateProductStatusUseCase(dependencies: self)
    }
    
    func resolve () -> GetAnalysisAreaOffersUseCase {
        DefaultGetAnalysisAreaOffersUseCase(dependencies: self)
    }
}
