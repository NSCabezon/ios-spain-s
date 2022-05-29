//
//  SendMoneySelectAccountDependenciesResolver.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol SendMoneySelectAccountDependenciesResolver {
    var external: SendMoneySelectAccountExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> SendMoneyOperative
    func resolve() -> SendMoneySelectAccountViewModel
    func resolve() -> SendMoneySelectAccountViewController
    func resolve() -> SendMoneyOperativeCoordinator
}

extension SendMoneySelectAccountDependenciesResolver {
    
    func resolve() -> SendMoneySelectAccountViewController {
        return SendMoneySelectAccountViewController(dependencies: self)
    }
    
    func resolve() -> SendMoneySelectAccountViewModel {
        return SendMoneySelectAccountViewModel(dependencies: self)
    }
}

struct SendMoneySelectAccountDependency: SendMoneySelectAccountDependenciesResolver {
    let dependencies: SendMoneySelectAccountExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: SendMoneyOperativeCoordinator
    let operative: SendMoneyOperative
    
    var external: SendMoneySelectAccountExternalDependenciesResolver {
        return dependencies
    }
    
    func resolve() -> SendMoneyOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> SendMoneyOperative {
        return operative
    }
}
