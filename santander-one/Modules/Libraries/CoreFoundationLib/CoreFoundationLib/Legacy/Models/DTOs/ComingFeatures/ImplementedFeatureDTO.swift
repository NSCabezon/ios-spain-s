//
//  AlreadyImplementedFeatureDTO.swift
//  Models
//
//  Created by José Carlos Estela Anguita on 25/02/2020.
//

import Foundation

public struct ImplementedFeatureDTO: Codable {
    
    public let identifier: String
    public let title: String
    public let description: String
    public let logo: String
    public let owner: String
    public let date: Date
    public let offerPayload: FeatureOfferPayLoadDTO?
}
