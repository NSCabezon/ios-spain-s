//
//  AnalysisAreaExternalDependenciesResolver.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 28/1/22.
//

import Foundation

public protocol AnalysisAreaExternalDependenciesResolver:
    AnalysisAreaHomeExternalDependenciesResolver,
    TimeSelectorExternalDependenciesResolver,
    AnalysisAreaProductsConfigurationExternalDependenciesResolver,
    DeleteOtherBankConnectionExternalDependenciesResolver,
    AnalysisAreaCategoryDetailExternalDependenciesResolver,
    AnalysisAreaMovementsFilterExternalDependenciesResolver {}
