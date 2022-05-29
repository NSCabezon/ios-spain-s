//
//  TestReactiveOperativeOTPExternalDependenciesResolver.swift
//  Operative-Unit-Tests
//
//  Created by David Gálvez Alonso on 23/3/22.
//

import CoreTestData
import CoreFoundationLib

@testable import Operative

struct TestReactiveOperativeOTPExternalDependenciesResolver: ReactiveOperativeOTPExternalDependenciesResolver, MockReactiveOperativeExternalDependenciesResolver {
    
    private let dataBinding = DataBindingObject()

    init() {}
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> OTPViewModelProtocol {
        fatalError()
    }
    
    func resolve() -> ReactiveOperativeOTPViewController {
        fatalError()
    }
    
    func resolve() -> OperativeCoordinator {
        fatalError()
    }
    
    func resolve() -> OTPConfigurationProtocol? {
        nil
    }
    
    func resolve() -> APPNotificationManagerBridgeProtocol? {
        return MockAPPNotificationManagerBridge()
    }
}
