//
//  LoginSessionCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import Foundation
import CoreFoundationLib

protocol LoginSessionResolverCapable {
    var dependenciesEngine: DependenciesDefault { get }
}

extension LoginSessionResolverCapable {
    func registerSessionDependencies() {
        self.dependenciesEngine.register(for: LoginSessionLayer.self) { resolver in
            return LoginSessionLayer(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetNeedUpdatePasswordUseCase.self) { resolver in
            return SetNeedUpdatePasswordUseCase(dependenciesEngine: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: SetLastLoginDateUseCase.self) { resolver in
            return SetLastLoginDateUseCase(dependenciesResolver: resolver)
        }
    }
}
