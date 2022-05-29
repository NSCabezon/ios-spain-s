//
//  MerchantListEntity.swift
//  Models
//
//  Created by César González Palomino on 03/03/2021.
//

import Foundation

public final class MerchantListEntity: DTOInstantiable {
    public let dto: MerchantListDTO
    
    public init(_ dto: MerchantListDTO) {
        self.dto = dto
    }
    
    public var merchantEntities: [MerchantEntity] {
        guard let dtoMerchantList = dto.merchantList else { return [MerchantEntity]() }
        return dtoMerchantList.map { MerchantEntity($0) }
    }
}
