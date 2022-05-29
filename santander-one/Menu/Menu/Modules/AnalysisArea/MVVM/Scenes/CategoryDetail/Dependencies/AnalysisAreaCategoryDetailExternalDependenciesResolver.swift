//
//  AnalysisAreaCategoryDetailExternalDependenciesResolver.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 29/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIKit

public protocol AnalysisAreaCategoryDetailExternalDependenciesResolver: AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func categoryDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func movementsFilterCoordinator() -> BindableCoordinator
    func resolve() -> BaseURLProvider
}

public extension AnalysisAreaCategoryDetailExternalDependenciesResolver {
    func categoryDetailCoordinator() -> BindableCoordinator {
        return DefaultAnalysisAreaCategoryDetailCoordinator(dependencies: self, navigationController: resolve())
    }
}
