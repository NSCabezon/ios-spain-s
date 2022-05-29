//
//  GlobalAppKeywordsDTO.swift
//  Models
//
//  Created by Johnatan Zavaleta Milla on 10/06/2021.
//

public struct GlobalAppKeywordsDTO: Codable {
    public let icon: String
    public let title: String
    public let deepLink: String
    public let keyWords: [String]
}
