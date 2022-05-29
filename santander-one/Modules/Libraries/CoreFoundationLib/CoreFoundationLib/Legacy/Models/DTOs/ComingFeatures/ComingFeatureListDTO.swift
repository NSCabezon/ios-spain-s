//
//  ComingFeatureListDTO.swift
//  Models
//
//  Created by José Carlos Estela Anguita on 25/02/2020.
//

import Foundation

public struct ComingFeatureListDTO: Codable {
    
    public let comingFeatures: [ComingFeatureDTO]
    public let alreadyImplementedFeatures: [ImplementedFeatureDTO]
    
    public init(comingFeatures: [ComingFeatureDTO], alreadyImplementedFeatures: [ImplementedFeatureDTO]) {
        self.comingFeatures = comingFeatures
        self.alreadyImplementedFeatures = alreadyImplementedFeatures
    }
}

extension ComingFeatureListDTO: DateParseable {
    
    public static var formats: [String: String] {
        return [
            "comingFeatures.date": "MM/yyyy",
            "alreadyImplementedFeatures.date": "dd/MM/yyyy"
        ]
    }
}
