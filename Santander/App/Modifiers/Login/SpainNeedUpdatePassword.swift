//
//  SpainNeedUpdatePassword.swift
//  Santander
//
//  Created by Andres Aguirre Juarez on 19/11/21.
//

import Foundation
import CoreFoundationLib
import Login

class SpainNeedUpdatePassword: SetSetNeedUpdatePasswordDelegateProtocol {
    var dependenciesEngine: DependenciesInjector & DependenciesResolver
    
    init(dependenciesEngine: DependenciesInjector & DependenciesResolver) {
        self.dependenciesEngine = dependenciesEngine
    }
    
    func register(_ forceToUpdatePassword: Bool) {
        let configuration = SetNeedUpdatePasswordConfiguration(forceToUpdatePassword: forceToUpdatePassword)
        dependenciesEngine.register(for: SetNeedUpdatePasswordConfiguration.self) { _ in
            return configuration
        }
    }
}
