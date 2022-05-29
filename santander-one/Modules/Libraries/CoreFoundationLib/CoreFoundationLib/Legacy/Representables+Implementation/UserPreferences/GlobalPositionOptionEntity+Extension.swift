//
//  GlobalPositionOptionEntity+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension GlobalPositionOptionEntity {
    func value() -> Int {
        return self.rawValue
    }
    
    func titleKey() -> String {
        switch self {
        case .classic:
            return "onboarding_title_classic"
        case .simple:
            return "onboarding_title_simple"
        case .smart:
            return "onboarding_title_young"
        }
    }
    
    func descriptionKey() -> String {
        switch self {
        case .classic:
            return "onboarding_text_classic"
        case .simple:
            return "onboarding_text_simple"
        case .smart:
            return "onboarding_text_young"
        }
    }
    
    func imageKey() -> String {
        switch self {
        case .classic:
            return "imgPgClassic"
        case .simple:
            return "imgPgSimple"
        case .smart:
            return "imgPgSmart"
        }
    }
    
    func trackName() -> String {
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
