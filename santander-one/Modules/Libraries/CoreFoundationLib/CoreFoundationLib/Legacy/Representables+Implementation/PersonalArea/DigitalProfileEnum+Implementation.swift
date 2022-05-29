//
//  DigitalProfileEnum+Implementation.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 4/2/22.
//

import CoreDomain

public extension DigitalProfileEnum {
    static func withPercentage(_ perc: Double) -> DigitalProfileEnum {
        switch perc {
        case ..<30:
            return .cadet
        case 30..<60:
            return .advanced
        case 60..<90:
            return .expert
        default:
            return .top
        }
    }
    
    func medal() -> String {
        switch self {
        case .cadet:
            return "icnCadet"
        case .advanced:
            return "icnAvance"
        case .expert:
            return "icnExpert"
        case .top:
            return "icnTop"
        }
    }
    
    func name() -> String {
        switch self {
        case .cadet:
            return "digitalProfile_label_cadet"
        case .advanced:
            return "digitalProfile_label_advanced"
        case .expert:
            return "digitalProfile_label_expert"
        case .top:
            return "digitalProfile_label_top"
        }
    }
}
