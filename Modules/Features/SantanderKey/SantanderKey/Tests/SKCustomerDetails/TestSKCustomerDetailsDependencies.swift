//
//  TestSKCustomerDetailsDependencies.swift
//  SantanderKey-Unit-Tests
//
//  Created by David Gálvez Alonso on 18/4/22.
//

import CoreFoundationLib

@testable import SantanderKey

struct TestSKCustomerDetailsDependencies: SKCustomerDetailsDependenciesResolver {
    
    var external: SKCustomerDetailsExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    
    init(external: SKCustomerDetailsExternalDependenciesResolver) {
        self.external = external
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> SKCustomerDetailsCoordinator {
        fatalError()
    }
}
