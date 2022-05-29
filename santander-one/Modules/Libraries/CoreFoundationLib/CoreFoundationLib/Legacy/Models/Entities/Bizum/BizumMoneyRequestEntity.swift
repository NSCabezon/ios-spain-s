//
//  BizumValidateMoneyRequestEntity.swift
//  Models
//
//  Created by Jose Ignacio de Juan Díaz on 01/12/2020.
//

import SANLegacyLibrary

public struct BizumMoneyRequestEntity: DTOInstantiable {
    public let dto: BizumMoneyRequestDTO
    
    public init(_ dto: BizumMoneyRequestDTO) {
        self.dto = dto
    }
    
    public var transferInfo: BizumTransferInfoEntity {
        return BizumTransferInfoEntity(dto.transferInfo)
    }
    
    public var operationId: String {
        return dto.operationId
    }
}
