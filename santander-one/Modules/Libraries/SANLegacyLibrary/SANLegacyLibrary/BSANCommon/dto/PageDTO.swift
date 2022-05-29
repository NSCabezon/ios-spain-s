//
//  PageDTO.swift
//  SANPTLibrary
//
//  Created by Boris Chirino Fernandez on 15/7/21.
//

public struct PageDTO: Codable {
    public let first: String
    public let next: String?
    public let previous: String?

    enum CodingKeys: String, CodingKey {
        case first = "_first"
        case next = "_next"
        case previous = "_prev"
    }
}
