//
//  SpainFeatureFlag.swift
//  Santander
//
//  Created by Tania Castellano Brasero on 18/4/22.
//
import CoreFoundationLib
import CoreDomain

public enum SpainFeatureFlag: String, CaseIterable {
    case bizumRegistration
    case santanderKey
}

extension SpainFeatureFlag: FeatureFlagRepresentable {
    public var identifier: String {
        return rawValue
    }
    
    public var description: String {
        switch self {
        case .bizumRegistration: return "Bizum Registration"
        case .santanderKey: return "Santander Key"
        }
    }
    
    public var defaultValue: FeatureValue {
        switch self {
        default:
            return .boolean(false)
        }
    }
}

