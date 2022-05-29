//
//  BizumRegistrationOperativeDependenciesResolver.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol BizumRegistrationOperativeDependenciesResolver {
    var external: BizumRegistrationOperativeExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> BizumRegistrationOperative
    func resolve() -> BizumRegistrationOperativeCoordinator
    func resolve() -> StepsCoordinator<BizumRegistrationOperativeStep>
}

extension BizumRegistrationOperativeDependenciesResolver {

}
