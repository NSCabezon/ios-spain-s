//
//  OfferPayLoad.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 26/02/2020.
//

import Foundation

public struct OfferPayLoad {
    
    private let dto: FeatureOfferPayLoadDTO
    public var preview: String {
        self.dto.preview
    }
    public var offerId: String {
        self.dto.offerId
    }
    
    public init(_ dto: FeatureOfferPayLoadDTO) {
        self.dto = dto
    }
}
