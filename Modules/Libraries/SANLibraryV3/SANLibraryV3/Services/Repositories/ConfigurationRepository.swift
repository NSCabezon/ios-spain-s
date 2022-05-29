//
//  ConfigurationRepository.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 28/5/21.
//

import SANSpainLibrary

final class ConfigurationDataRepository: ConfigurationRepository {

    var configuration: ConfigurationRepresentable

    init(configuration: ConfigurationRepresentable) {
        self.configuration = configuration
    }

    subscript<Value>(_ key: WritableKeyPath<ConfigurationRepresentable, Value>) -> Value? {
        get {
            return configuration[keyPath: key]
        }
        set {
            guard let value = newValue else { return }
            configuration[keyPath: key] = value
        }
    }
}
