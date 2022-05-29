//
//  ConfigurationRepository.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 28/5/21.
//

import Foundation

public protocol ConfigurationRepository {
    subscript<Value>(_ key: WritableKeyPath<ConfigurationRepresentable, Value>) -> Value? { get set }
}
