//
//  TransactionCategorizerDTO.swift
//
//  Created by Boris Chirino Fernandez on 22/12/2020.
//
public struct TransactionCategorizerDTO: Codable {
    public let category: String
    public let identifier: String?
    public let subcategory: String?
    
    private enum CodingKeys: String, CodingKey {
        case category
        case identifier = "id"
        case subcategory
    }
}
