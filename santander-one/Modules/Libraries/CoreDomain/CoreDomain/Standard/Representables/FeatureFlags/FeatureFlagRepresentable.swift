//
//  FeatureFlagRepresentable.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation

public protocol FeatureFlagRepresentable {
    var identifier: String { get }
    var description: String { get }
    var defaultValue: FeatureValue { get }
}

extension FeatureFlagRepresentable {
    
    public func eraseToAnyFeature() -> AnyFeatureFlag {
        return AnyFeatureFlag(feature: self)
    }
}

public enum FeatureValue {
    case boolean(Bool)
    
    public func isSameType(_ value: FeatureValue) -> Bool {
        switch (self, value) {
        case (.boolean, .boolean): return true
        }
    }
}

public struct AnyFeatureFlag: Hashable, FeatureFlagRepresentable {
    
    public var identifier: String {
        return feature.identifier
    }
    public var description: String {
        return feature.description
    }
    public var defaultValue: FeatureValue {
        return feature.defaultValue
    }
    
    private let feature: FeatureFlagRepresentable
    
    public init(feature: FeatureFlagRepresentable) {
        self.feature = feature
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(feature.identifier)
    }
    
    public static func == (lhs: AnyFeatureFlag, rhs: AnyFeatureFlag) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
