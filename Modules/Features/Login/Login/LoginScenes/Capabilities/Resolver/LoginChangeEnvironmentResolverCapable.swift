//
//  LoginChangeEnvironmentCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/26/20.
//

import Foundation
import CoreFoundationLib

protocol LoginChangeEnvironmentResolverCapable {
    var dependenciesEngine: DependenciesDefault { get }
}

extension LoginChangeEnvironmentResolverCapable {
    func registerEnvironmentDependencies() {
        self.dependenciesEngine.register(for: LoginEnvironmentLayer.self) { resolver in
            return LoginEnvironmentLayer(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetBSANCurrentEnvironmentUseCase.self) { resolver in
            return GetBSANCurrentEnvironmentUseCase(dependenciesResolver: resolver)
        }
    }
}
