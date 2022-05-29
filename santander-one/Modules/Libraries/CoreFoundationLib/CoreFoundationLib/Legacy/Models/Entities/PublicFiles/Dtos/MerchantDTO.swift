//
//  MerchantDTO.swift
//  Models
//
//  Created by César González Palomino on 03/03/2021.
//

import Foundation

public struct MerchantDTO: Codable {
    public let code: String
    public let name: [String]
    public let urlIcon: String?

    public init(code: String, name: [String], urlIcon: String?) {
        self.code = code
        self.name = name
        self.urlIcon = urlIcon
    }
}
