//
//  TimeSelectorExternalDependenciesResolver.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol TimeSelectorExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func timeSelectorCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
}

public extension TimeSelectorExternalDependenciesResolver {
    func timeSelectorCoordinator() -> BindableCoordinator {
        return DefaultTimeSelectorCoordinator(dependencies: self, navigationController: resolve())
    }
}
