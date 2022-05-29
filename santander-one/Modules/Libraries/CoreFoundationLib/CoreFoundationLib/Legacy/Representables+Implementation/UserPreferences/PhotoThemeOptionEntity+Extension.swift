//
//  PhotoThemeOptionEntity+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension PhotoThemeOptionEntity {
    func value() -> Int {
        return self.rawValue
    }
    
    func titleKey() -> String {
        switch self {
        case .geographic:
            return "onboarding_title_geographic"
        case .pets:
            return "onboarding_title_pet"
        case .geometric:
            return "onboarding_title_geometic"
        case .architecture:
            return "onboarding_title_architecture"
        case .youngs:
            return "onboarding_title_youngs"
        case .nature:
            return "onboarding_title_nature"
        case .sports:
            return "onboarding_title_sport"
        }
    }
    
    func descriptionKey() -> String {
        switch self {
        case .geographic:
            return "onboarding_text_geographic"
        case .pets:
            return "onboarding_text_pet"
        case .geometric:
            return "onboarding_text_geometic"
        case .architecture:
            return "onboarding_text_architecture"
        case .youngs:
            return "onboarding_text_youngs"
        case .nature:
            return "onboarding_text_nature"
        case .sports:
            return "onboarding_text_sport"
        }
    }
    
    func imageKey() -> String {
        switch self {
        case .geographic:
            return "imgGeographicalTheme"
        case .pets:
            return "imgPetsTheme"
        case .geometric:
            return "imgGeometryTheme"
        case .architecture:
            return "imgArchitectureTheme"
        case .youngs:
            return "imgSmartTheme"
        case .nature:
            return "imgNatureTheme"
        case .sports:
            return "imgSportsTheme"
        }
    }
}
