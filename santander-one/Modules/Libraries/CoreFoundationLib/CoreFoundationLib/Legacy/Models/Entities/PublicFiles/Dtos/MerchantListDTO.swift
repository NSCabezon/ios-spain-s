//
//  MerchantListDTO.swift
//  Models
//
//  Created by César González Palomino on 03/03/2021.
//

import Foundation

public struct MerchantListDTO: Codable {
    public let merchantList: [MerchantDTO]?

    public init(merchantList: [MerchantDTO]?) {
        self.merchantList = merchantList
    }
}
