//
//  BooleanFeatureFlag.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol BooleanFeatureFlag {
    func fetch(_ feature: FeatureFlagRepresentable) -> AnyPublisher<Bool, Never>
}

public struct DefaultBooleanFeatureFlag: BooleanFeatureFlag {
    
    private let repository: FeatureFlagsRepository
    
    public init(dependencies: FeatureFlagsRepositoryDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
    
    public func fetch(_ feature: FeatureFlagRepresentable) -> AnyPublisher<Bool, Never> {
        return repository
                .fetch(feature)
                .compactMap {
                    guard case let .boolean(value) = $0 else { return nil }
                    return value
                }
                .eraseToAnyPublisher()
    }
}
