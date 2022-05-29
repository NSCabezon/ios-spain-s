//
//  BizumValidateMoneyRequestEntity.swift
//  Models
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//

import SANLegacyLibrary

public struct BizumValidateMoneyRequestEntity: DTOInstantiable {
    public let dto: BizumValidateMoneyRequestDTO
    
    public init(_ dto: BizumValidateMoneyRequestDTO) {
        self.dto = dto
    }
    
    public var transferInfo: BizumTransferInfoEntity {
        return BizumTransferInfoEntity(dto.transferInfo)
    }
    
    public var operationId: String {
        return dto.operationId
    }
    
    public var beneficiaryAlias: String? {
        return dto.beneficiaryAlias
    }
}
