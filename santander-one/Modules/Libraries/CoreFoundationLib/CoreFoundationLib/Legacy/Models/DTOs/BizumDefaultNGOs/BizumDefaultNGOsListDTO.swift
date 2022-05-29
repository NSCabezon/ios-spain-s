//
//  BizumDefaultNGOsListDTO.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 16/02/2021.
//

import Foundation

public struct BizumDefaultNGOsListDTO: Codable {
    public let defaultNGOs: [BizumDefaultNGODTO]
    
    public init(defaultNGOs: [BizumDefaultNGODTO]) {
        self.defaultNGOs = defaultNGOs
    }
    
    enum CodingKeys: String, CodingKey {
        case defaultNGOs = "default_ongs"
    }
}
