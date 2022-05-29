//
//  LastLoginInfoDTOEntity.swift
//  GlobalPosition
//
//  Created by Laura González on 30/06/2020.
//

import Foundation

public class LastLoginInfoDTOEntity: Codable {
    public var previousLoginDate: Date?
    public var currentLoginDate: Date = Date()
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        previousLoginDate = try (container.decodeIfPresent(Date.self, forKey: .previousLoginDate) ?? Date())
        currentLoginDate = try (container.decodeIfPresent(Date.self, forKey: .currentLoginDate) ?? Date())
    }
}

extension LastLoginInfoDTOEntity {
    enum CodingKeys: String, CodingKey {
        case previousLoginDate
        case currentLoginDate
    }
}
