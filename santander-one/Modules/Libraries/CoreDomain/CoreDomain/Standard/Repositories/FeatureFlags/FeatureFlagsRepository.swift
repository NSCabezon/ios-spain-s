//
//  FeatureFlagsRepository.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import OpenCombine

public protocol FeatureFlagsRepository {
    func fetchAll() -> AnyPublisher<[AnyFeatureFlag: FeatureValue], Never>
    func fetch(_ feature: FeatureFlagRepresentable) -> AnyPublisher<FeatureValue, Never>
    func save(value: FeatureValue, for feature: FeatureFlagRepresentable)
}
