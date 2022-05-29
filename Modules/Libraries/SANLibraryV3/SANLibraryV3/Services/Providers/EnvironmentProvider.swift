//
//  EnvironmentProvider.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import SANSpainLibrary

public protocol EnvironmentProvider {
    func getEnvironment() -> EnvironmentRepresentable
    func update(environment: EnvironmentRepresentable)
}
