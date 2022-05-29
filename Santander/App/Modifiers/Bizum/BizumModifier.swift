//
//  BizumModifier.swift
//  Santander
//
//  Created by Tania Castellano Brasero on 12/4/22.
//

import CoreFoundationLib
import Bizum
import OpenCombine

protocol BizumModifierDependenciesResolver {
    func resolve() -> BizumRegistrationExternalDependenciesResolver
    var oldDependencies: DependenciesResolver { get }
}

protocol BizumModifierProtocol {
    func checkRegistration(completion: @escaping (Bool) -> Void)
    func goToRegistration()
}

final class BizumModifier: BizumModifierProtocol {
    let dependencies: BizumModifierDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []

    init(dependencies: BizumModifierDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func checkRegistration(completion: @escaping (Bool) -> Void) {
        let booleanFeatureFlag: BooleanFeatureFlag = dependencies.oldDependencies.resolve()
        booleanFeatureFlag.fetch(SpainFeatureFlag.bizumRegistration)
            .sink { result in
                completion(result)
            }
            .store(in: &subscriptions)
    }

    func goToRegistration() {
        let dependencies: BizumRegistrationExternalDependenciesResolver = dependencies.resolve()
        dependencies.registrationCoordinator().start()
    }
}

extension ModuleDependencies: BizumRegistrationExternalDependenciesResolver {}

extension ModuleDependencies: BizumModifierDependenciesResolver {
    func resolve() -> BizumRegistrationExternalDependenciesResolver {
        return self
    }
    
    var oldDependencies: DependenciesResolver {
        self.oldResolver
    }
}
