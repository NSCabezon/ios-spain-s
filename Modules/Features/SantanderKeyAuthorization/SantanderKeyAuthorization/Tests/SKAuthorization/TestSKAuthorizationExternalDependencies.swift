//
//  TestSKCustomerDetailsExternalDependencies.swift
//  SantanderKey-Unit-Tests
//
//  Created by David Gálvez Alonso on 18/4/22.
//

import CoreTestData
import CoreFoundationLib
import UI
import SANSpainLibraryAuthorization

@testable import SantanderKey

struct TestSKAuthorizationExternalDependencies: SKAuthorizationExternalDependenciesResolver {
    
    let injector: MockDataInjector
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }

    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> CompilationProtocol {
        return CompilationMock()
    }
}
