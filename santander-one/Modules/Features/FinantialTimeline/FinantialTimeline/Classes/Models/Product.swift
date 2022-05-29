//
//  Product.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 12/12/2019.
//

import Foundation

public struct Product: Codable {
    let displayNumber: String
    var accountCode: String? {didSet { code = accountCode } }
    var cardCode: String? {didSet { code = cardCode } }
    var code: String?
    
    enum CodingKeys: String, CodingKey {
        case displayNumber
        case accountCode = "accountId"
        case cardCode = "cardId"
        case code
    }
}

public struct AccountList: Codable {
    let accountsDataList: [Product]
}

public struct CadsList: Codable {
    let cards: [Product]
}
