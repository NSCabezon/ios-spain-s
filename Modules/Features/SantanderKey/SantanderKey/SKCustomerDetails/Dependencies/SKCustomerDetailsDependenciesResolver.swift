//
//  SKCustomerDetailsDependenciesResolver.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol SKCustomerDetailsDependenciesResolver {
    var external: SKCustomerDetailsExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> SKCustomerDetailsViewController
    func resolve() -> SKCustomerDetailsViewModel
    func resolve() -> GetOneFaqsUseCase
    func resolve() -> SKCustomerDetailsCoordinator
}

extension SKCustomerDetailsDependenciesResolver {
    
    func resolve() -> SKCustomerDetailsViewController {
        return SKCustomerDetailsViewController(dependencies: self)
    }
    
    func resolve() -> SKCustomerDetailsViewModel {
        return SKCustomerDetailsViewModel(dependencies: self)
    }
    
    func resolve() -> SKCustomerDetailsUseCase {
        return DefaultSKCustomerDetailsUseCase(dependencies: self)
    }
    
    func resolve() -> GetOneFaqsUseCase {
        return external.resolve()
    }
}
