//
//  RegistrationExternalDependenciesResolver.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 11/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIKit

public protocol BizumRegistrationExternalDependenciesResolver: BizumRegistrationOperativeExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func registrationCoordinator() -> BindableCoordinator
    func resolve() -> DefaultBizumRegistrationOperativeCoordinator
    func resolve() -> TrackerManager
}

public extension BizumRegistrationExternalDependenciesResolver {
    func registrationCoordinator() -> BindableCoordinator {
        BizumDefaultRegistrationCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolve() -> DefaultBizumRegistrationOperativeCoordinator {
        DefaultBizumRegistrationOperativeCoordinator(dependencies: self, navigationController: resolve())
    }
}
