//
//  PublicProductsDTO.swift
//  Models
//
//  Created by alvola on 28/04/2020.
//

public struct PublicProductsDTO: Codable {
    public let publicProducts: [PublicProduct]
    public let stockHolders: [PublicProduct]
}
