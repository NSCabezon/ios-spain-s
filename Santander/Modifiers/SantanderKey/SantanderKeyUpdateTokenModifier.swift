//
//  SantanderKeyUpdateTokenModifier.swift
//  Santander
//
//  Created by Ali Ghanbari Dolatshahi on 25/4/22.
//

import RetailLegacy
import CoreFoundationLib
import SantanderKey
import SANSpainLibrary
import UI

protocol SKUpdateTokenModifierDependenciesResolver {
    func resolve() -> SantanderKeyUpdateTokenUseCaseProtocol
    func resolve() -> UseCaseHandler
}

final class SKUpdateTokenModifier: SantanderKeyUpdateTokenModifierProtocol {
    let dependencies: SKUpdateTokenModifierDependenciesResolver
    
    init(dependencies: SKUpdateTokenModifierDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func updateToken(completion: @escaping (Bool) -> Void) {
        let useCase: SantanderKeyUpdateTokenUseCaseProtocol = dependencies.resolve()
        Scenario(useCase: useCase)
            .execute(on: dependencies.resolve())
            .onSuccess {
                completion(true)
            }
    }
}
