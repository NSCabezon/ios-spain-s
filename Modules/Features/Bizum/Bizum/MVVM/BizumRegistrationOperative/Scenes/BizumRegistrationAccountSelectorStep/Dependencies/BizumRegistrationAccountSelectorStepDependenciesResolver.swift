//
//  BizumRegistrationAccountSelectorStepDependenciesResolver.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol BizumRegistrationAccountSelectorStepDependenciesResolver {
    var external: BizumRegistrationAccountSelectorStepExternalDependenciesResolver { get }
    func resolve() -> BizumRegistrationAccountSelectorStepViewController
    func resolve() -> BizumRegistrationAccountSelectorStepViewModel
    func resolve() -> DataBinding
    func resolve() -> BizumRegistrationOperative
}

extension BizumRegistrationAccountSelectorStepDependenciesResolver {
    
    func resolve() -> BizumRegistrationAccountSelectorStepViewController {
        return BizumRegistrationAccountSelectorStepViewController(dependencies: self)
    }
    
    func resolve() -> BizumRegistrationAccountSelectorStepViewModel {
        return BizumRegistrationAccountSelectorStepViewModel(dependencies: self)
    }
}

struct BizumRegistrationAccountSelectorDependency: BizumRegistrationAccountSelectorStepDependenciesResolver {
    let dependencies: BizumRegistrationAccountSelectorStepExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: BizumRegistrationOperativeCoordinator
    let operative: BizumRegistrationOperative
    
    var external: BizumRegistrationAccountSelectorStepExternalDependenciesResolver {
        return dependencies
    }
    
    func resolve() -> BizumRegistrationOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> BizumRegistrationOperative {
        return operative
    }
}
