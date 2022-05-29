//
//  AppInfoDTO.swift
//  Models
//
//  Created by alvola on 22/04/2020.
//

public struct AppVersionsInfoDTO {
    
    public var versions: [String: [String: String]]
    
    public init(versions: [String: [String: String]]) {
        self.versions = versions
    }
    
    public var getStringRepresentation: String {
        return versions.description
    }
}
