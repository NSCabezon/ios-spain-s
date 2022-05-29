//
//  ReactiveOperativeOTPExternalDependenciesResolver.swift
//  Operative
//
//  Created by David Gálvez Alonso on 17/3/22.
//

import CoreFoundationLib

public protocol ReactiveOperativeOTPExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> DataBinding
    func resolve() -> OTPViewModelProtocol
    func resolve() -> ReactiveOperativeOTPViewController
    func resolve() -> OperativeCoordinator
    func resolve() -> OTPConfigurationProtocol?
    func resolve() -> APPNotificationManagerBridgeProtocol?
}

public extension ReactiveOperativeOTPExternalDependenciesResolver {
    func resolve() -> ReactiveOperativeOTPViewController {
        return ReactiveOperativeOTPViewController(dependencies: self)
    }
}
