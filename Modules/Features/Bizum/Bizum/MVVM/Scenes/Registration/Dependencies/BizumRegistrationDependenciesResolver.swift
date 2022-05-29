//
//  RegistrationDependenciesResolver.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 11/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol BizumRegistrationDependenciesResolver {
    var external: BizumRegistrationExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> BizumRegistrationCoordinator
}

extension BizumRegistrationDependenciesResolver {
    
    func resolve() -> BizumRegistrationViewController {
        return BizumRegistrationViewController(dependencies: self)
    }
    
    func resolve() -> BizumRegistrationViewModel {
        return BizumRegistrationViewModel(dependencies: self)
    }
}
