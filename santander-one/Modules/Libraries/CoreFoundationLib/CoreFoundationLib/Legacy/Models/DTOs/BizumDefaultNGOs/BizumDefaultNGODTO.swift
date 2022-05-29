//
//  BizumDefaultNGODTO.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 16/02/2021.
//

import Foundation

public struct BizumDefaultNGODTO: Codable {
    public let identifier: String
    public let name: String
    public let alias: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "identificador"
        case name = "nombreOrganizacion"
        case alias = "aliasOrganizacion"
    }
}
