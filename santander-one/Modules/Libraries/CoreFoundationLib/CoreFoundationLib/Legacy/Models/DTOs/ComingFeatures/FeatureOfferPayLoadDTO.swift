//
//  FeatureOfferPayLoadDTO.swift
//  Models
//
//  Created by José Carlos Estela Anguita on 25/02/2020.
//

import Foundation

public struct FeatureOfferPayLoadDTO: Codable {
    
    public let preview: String
    public let offerId: String
    
    public init(preview: String, offerId: String) {
        self.preview = preview
        self.offerId = offerId
    }
}
