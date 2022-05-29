//
//  DefaultFeatureFlagsRepository.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol FeatureFlagsRepositoryDependenciesResolver {
    func resolve() -> FeatureFlagsRepository
}

public final class DefaultFeatureFlagsRepository: FeatureFlagsRepository {
    
    private var features: [AnyFeatureFlag: FeatureValue]
    
    public init(features: [FeatureFlagRepresentable]) {
        self.features = features.eraseToAnyFeatures().toDictionaryWithDefaultValue()
    }
    
    public func fetchAll() -> AnyPublisher<[AnyFeatureFlag: FeatureValue], Never> {
        return Just(features).eraseToAnyPublisher()
    }
    
    public func fetch(_ feature: FeatureFlagRepresentable) -> AnyPublisher<FeatureValue, Never> {
        guard let value = features[feature.eraseToAnyFeature()] else {
            save(value: feature.defaultValue, for: feature)
            return Just(feature.defaultValue).eraseToAnyPublisher()
        }
        return Just(value).eraseToAnyPublisher()
    }
    
    public func save(value: FeatureValue, for feature: FeatureFlagRepresentable) {
        guard feature.defaultValue.isSameType(value) else { return } // Only available if the type is the same (to avoid saving a string in a boolean type)
        features[feature.eraseToAnyFeature()] = value
    }
}

private extension Array where Element == FeatureFlagRepresentable {
    
    func eraseToAnyFeatures() -> [AnyFeatureFlag] {
        return map { $0.eraseToAnyFeature() }
    }
}

private extension Array where Element: FeatureFlagRepresentable {
    
    func eraseToAnyFeatures() -> [AnyFeatureFlag] {
        return map { $0.eraseToAnyFeature() }
    }
    
    func toDictionaryWithDefaultValue() -> [AnyFeatureFlag: FeatureValue] {
        return Dictionary(uniqueKeysWithValues: map({ ($0.eraseToAnyFeature(), $0.defaultValue) }))
    }
}
