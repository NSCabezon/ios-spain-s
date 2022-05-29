//
//  AnalysisAreaProductsConfigurationDependenciesResolver.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

 import UI
 import CoreFoundationLib
 import Foundation
 import CoreFoundationLib
 import OpenCombine
 import CoreDomain
 
protocol AnalysisAreaProductsConfigurationDependenciesResolver {
    var external: AnalysisAreaProductsConfigurationExternalDependenciesResolver { get }
    func resolve() -> AnalysisAreaProductsConfigurationViewModel
    func resolve() -> AnalysisAreaProductsConfigurationViewController
    func resolve() -> AnalysisAreaProductsConfigurationCoordinator
    func resolve() -> DataBinding
    func resolve() -> SetAnalysisAreaPreferencesUseCase
}

extension AnalysisAreaProductsConfigurationDependenciesResolver {
    func resolve() -> AnalysisAreaProductsConfigurationViewController {
        AnalysisAreaProductsConfigurationViewController(dependencies: self)
    }
    
    func resolve() -> AnalysisAreaProductsConfigurationViewModel {
        AnalysisAreaProductsConfigurationViewModel(dependencies: self)
    }
    
    func resolve() -> SetAnalysisAreaPreferencesUseCase {
        DefaultGetAnalysisAreaPreferencesUseCase(dependencies: self)
    }
}
