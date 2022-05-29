//
//  AnalysisAreaMovementsFilterExternalDependenciesResolver.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 4/4/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol AnalysisAreaMovementsFilterExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func movementsFilterCoordinator() -> BindableCoordinator
}

public extension AnalysisAreaMovementsFilterExternalDependenciesResolver {
    func movementsFilterCoordinator() -> BindableCoordinator{
        return DefaultAnalysisAreaMovementsFilterCoordinator(dependencies: self, navigationController: resolve())
    }
}
