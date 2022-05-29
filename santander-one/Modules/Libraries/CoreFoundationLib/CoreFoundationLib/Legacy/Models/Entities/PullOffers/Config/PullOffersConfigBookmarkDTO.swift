//
//  PullOffersConfigBookmarkDTO.swift
//  Models
//
//  Created by David Gálvez Alonso on 27/07/2020.
//

public struct PullOffersConfigBookmarkDTO: Codable {
    public let title: String?
    public let size: String?
    public let offersId: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case title
        case size
        case offersId
    }
}
