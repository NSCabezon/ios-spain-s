//
//  TestPrivateSubMenuDependenciesResolver.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreFoundationLib
import CoreTestData
@testable import PrivateMenu

struct TestPrivateSubmenuDependencies: PrivateSubMenuDependenciesResolver {
    let injector: MockDataInjector
    let external: PrivateSubMenuExternalDependenciesResolver
    
    let coordinatorSpy = PrivateSubMenuCoordinatorSpy()
    let dataBinding: DataBinding
    
    init(injector: MockDataInjector, externalDependencies: TestPrivateSubMenuExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
        self.dataBinding = DataBindingObject()
    }
    
    func resolve() -> DataBinding {
        self.dataBinding
    }
    
    func resolve() -> PrivateSubMenuCoordinator {
        self.coordinatorSpy
    }
}
