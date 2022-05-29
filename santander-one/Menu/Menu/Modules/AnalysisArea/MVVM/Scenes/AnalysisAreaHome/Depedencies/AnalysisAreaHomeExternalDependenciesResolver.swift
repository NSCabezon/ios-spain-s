//
//  AnalysisAreaHomeExternalDependenciesResolver.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIKit

public protocol AnalysisAreaHomeExternalDependenciesResolver: AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> TrackerManager
    func resolve() -> UserSessionFinancialHealthRepository
    func analysisAreaHomeCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func timeSelectorCoordinator() -> BindableCoordinator
    func productsConfigurationCoordinator() -> BindableCoordinator
    func categoryDetailCoordinator() -> BindableCoordinator
    func offersCoordinator() -> BindableCoordinator
    func oldAnalysisAreaHomeCoordinator() -> BindableCoordinator
    func resolve() -> BaseURLProvider
    func resolve() -> DependenciesResolver
    func resolve() -> GetCandidateOfferUseCase
}

public extension AnalysisAreaHomeExternalDependenciesResolver {
    func analysisAreaHomeCoordinator() -> BindableCoordinator {
        return DefaultAnalysisAreaCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func oldAnalysisAreaHomeCoordinator() -> BindableCoordinator {
        return OldAnalysisAreaCoordinator(dependencies: self, navigationController: resolve())
    }
}
