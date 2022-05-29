//
//  MerchantEntity.swift
//  Models
//
//  Created by César González Palomino on 03/03/2021.
//

import Foundation

public final class MerchantEntity: DTOInstantiable {
    
    public let dto: MerchantDTO
    
    public var code: String {
        return dto.code 
    }
    public var names: [String] {
        return dto.name
    }
    public var iconUrl: String? {
        return dto.urlIcon
    }
 
    public init(_ dto: MerchantDTO) {
        self.dto = dto
    }
}
