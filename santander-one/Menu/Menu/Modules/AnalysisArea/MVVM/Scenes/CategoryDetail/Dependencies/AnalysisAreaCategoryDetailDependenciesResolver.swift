//
//  AnalysisAreaCategoryDetailDependenciesResolver.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 29/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol AnalysisAreaCategoryDetailDependenciesResolver {
    var external: AnalysisAreaCategoryDetailExternalDependenciesResolver { get }
    func resolve() -> AnalysisAreaCategoryDetailViewModel
    func resolve() -> AnalysisAreaCategoryDetailViewController
    func resolve() -> AnalysisAreaCategoryDetailCoordinator
    func resolve() -> DataBinding
    func resolve() -> GetAnalysisAreaCategoryDetailInfoUseCase
    func resolve() -> GetAnalysisAreaTransactionsUseCase
}

extension AnalysisAreaCategoryDetailDependenciesResolver {
    
    func resolve() -> AnalysisAreaCategoryDetailViewController {
        return AnalysisAreaCategoryDetailViewController(dependencies: self)
    }
    
    func resolve() -> AnalysisAreaCategoryDetailViewModel {
        return AnalysisAreaCategoryDetailViewModel(dependencies: self)
    }
    
    func resolve() -> GetAnalysisAreaCategoryDetailInfoUseCase {
        return DefaultGetAnalysisAreaCategoryUseCase(dependencies: self)
    }

    func resolve() -> GetAnalysisAreaTransactionsUseCase {
        return DefaultGetAnalysisAreaTransactionsUseCase(dependencies: self)
    }
}
