//
//  SegmentTypeEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 02/01/2020.
//

import Foundation

public enum SegmentTypeEntity {
    case select
    case smart
    case retail
    case privateBanking
    case custome(image: String)
    
    public func segmentImage() -> String {
        switch self {
        case .privateBanking:
            return "icnPbpg"
        case .retail:
            return "icnSantander"
        case .select:
            return "icnSelectPg"
        case .smart:
            return "icnSmartPg"
        case let .custome(image):
            return image
        }
    }
}
