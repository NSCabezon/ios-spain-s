//
//  TestReactiveOperativeSignatureExternalDependenciesResolver.swift
//  Operative-Unit-Tests
//
//  Created by David Gálvez Alonso on 28/3/22.
//

import CoreTestData
import CoreFoundationLib

@testable import Operative

struct TestReactiveSignatureExternalDependenciesResolver: ReactiveOperativeSignatureExternalDependenciesResolver, MockReactiveOperativeExternalDependenciesResolver {
    
    private let dataBinding = DataBindingObject()

    init() {}
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> UINavigationController { fatalError() }
    func resolve() -> DependenciesResolver { fatalError() }
    func resolve() -> SignatureViewModelProtocol { fatalError() }
    func resolve() -> ReactiveOperativeSignatureViewController { fatalError() }
    func resolve() -> OperativeCoordinator { fatalError() }
}
