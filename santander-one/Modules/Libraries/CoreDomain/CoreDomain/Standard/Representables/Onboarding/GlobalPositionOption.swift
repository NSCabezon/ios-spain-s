//
//  GlobalPositionOption.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation

public enum GlobalPositionOption: Int, CaseIterable {
    case classic = 0
    case simple
    case smart
    
    public func value() -> Int {
        self.rawValue
    }
    
    public func titleKey() -> String {
        switch self {
        case .classic:
            return "onboarding_title_classic"
        case .simple:
            return "onboarding_title_simple"
        case .smart:
            return "onboarding_title_young"
        }
    }
    
    public func descriptionKey() -> String {
        switch self {
        case .classic:
            return "onboarding_text_classic"
        case .simple:
            return "onboarding_text_simple"
        case .smart:
            return "onboarding_text_young"
        }
    }
    
    public func imageKey() -> String {
        switch self {
        case .classic:
            return "imgPgClassic"
        case .simple:
            return "imgPgSimple"
        case .smart:
            return "imgPgSmart"
        }
    }
    
    public func trackName() -> String {
        switch self {
        case .classic:
            return "clas"
        case .simple:
            return "sen"
        case .smart:
            return "smrt"
        }
    }
}
