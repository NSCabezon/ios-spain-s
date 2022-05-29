 //
//  AnalysisAreaProductsConfigurationExternalDependenciesResolver.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

public protocol AnalysisAreaProductsConfigurationExternalDependenciesResolver: AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func productsConfigurationCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func deleteOtherBankConnectionCoordinator() -> BindableCoordinator
    func resolve() -> BaseURLProvider
    func offersCoordinator() -> BindableCoordinator
}

public extension AnalysisAreaProductsConfigurationExternalDependenciesResolver {
    func productsConfigurationCoordinator() -> BindableCoordinator {
        DefaultAnalysisAreaProductsConfigurationCoordinator(dependencies: self, navigationController: resolve())
    }
}
