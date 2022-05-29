//
//  BizumMoneyRequestMultiEntity.swift
//  Models
//
//  Created by Jose Ignacio de Juan Díaz on 02/12/2020.
//

import SANLegacyLibrary

public struct BizumMoneyRequestMultiEntity: DTOInstantiable {
    public let dto: BizumMoneyRequestMultiDTO
    
    public init(_ dto: BizumMoneyRequestMultiDTO) {
        self.dto = dto
    }
    
    public var errorCode: String {
        return dto.errorCode
    }
}
