//
//  PullOffersConfigRangesDTO.swift
//  Models
//
//  Created by Tania Castellano Brasero on 31/05/2021.
//

import Foundation

public struct PullOffersConfigRangesDTO: Codable {
    public let identifier: String
    public let greaterAndEqualThan: String?
    public let lessThan: String?
    public let title: String?
    public let icon: String?
    public let offersId: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case greaterAndEqualThan
        case lessThan
        case title
        case icon
        case offersId
    }
}
