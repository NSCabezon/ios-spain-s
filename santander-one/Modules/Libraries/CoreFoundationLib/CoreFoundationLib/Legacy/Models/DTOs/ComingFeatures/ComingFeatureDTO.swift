//
//  ComingFeatureDTO.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 19/02/2020.
//

import Foundation

public struct ComingFeatureDTO: Codable {

    public let identifier: String
    public let title: String
    public let description: String
    public let logo: String
    public let owner: String
    public let date: Date
    public let offerPayload: FeatureOfferPayLoadDTO?
}
