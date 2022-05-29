//
//  AnalysisAreaMovementsFilterDependenciesResolver.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 4/4/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol AnalysisAreaMovementsFilterDependenciesResolver {
    var external: AnalysisAreaMovementsFilterExternalDependenciesResolver { get }
    func resolve() -> AnalysisAreaMovementsFilterViewModel
    func resolve() -> AnalysisAreaMovementsFilterViewController
    func resolve() -> AnalysisAreaMovementsFilterCoordinator
    func resolve() -> DataBinding
}

extension AnalysisAreaMovementsFilterDependenciesResolver {
    
    func resolve() -> AnalysisAreaMovementsFilterViewController {
        return AnalysisAreaMovementsFilterViewController(dependencies: self)
    }
    
    func resolve() -> AnalysisAreaMovementsFilterViewModel {
        return AnalysisAreaMovementsFilterViewModel(dependencies: self)
    }
}
