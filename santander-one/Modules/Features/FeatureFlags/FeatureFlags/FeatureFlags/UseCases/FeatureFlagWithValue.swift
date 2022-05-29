//
//  FeatureFlagWithValue.swift
//  FeatureFlags
//
//  Created by José Carlos Estela Anguita on 17/3/22.
//

import Foundation
import CoreDomain

struct FeatureFlagWithValue {
    let feature: AnyFeatureFlag
    let value: FeatureValue
}

extension FeatureFlagWithValue: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(feature.identifier)
    }
    
    static func == (lhs: FeatureFlagWithValue, rhs: FeatureFlagWithValue) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
