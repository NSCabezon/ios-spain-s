//
//  TestPrivateMenuDependencies.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreFoundationLib
import CoreTestData
@testable import PrivateMenu

struct TestPrivateMenuDependencies: PrivateMenuDependenciesResolver {
    let injector: MockDataInjector
    let external: PrivateMenuExternalDependenciesResolver
    
    let coordinatorSpy = PrivateMenuCoordinatorSpy()
    let dataBinding: DataBinding
    
    init(injector: MockDataInjector, externalDependencies: TestPrivateMenuExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
        self.dataBinding = DataBindingObject()
    }
    
    func resolve() -> DataBinding {
        self.dataBinding
    }
    
    func resolve() -> PrivateMenuCoordinator {
        self.coordinatorSpy
    }
}

