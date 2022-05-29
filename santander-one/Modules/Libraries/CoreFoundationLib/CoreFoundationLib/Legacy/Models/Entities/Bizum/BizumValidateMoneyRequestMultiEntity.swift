//
//  BizumValidateMoneyRequestMultiEntity.swift
//  Models
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//

import SANLegacyLibrary

public struct BizumValidateMoneyRequestMultiEntity: DTOInstantiable {
    public let dto: BizumValidateMoneyRequestMultiDTO
    
    public init(_ dto: BizumValidateMoneyRequestMultiDTO) {
        self.dto = dto
    }
    
    public var transferInfo: BizumTransferInfoEntity {
        return BizumTransferInfoEntity(dto.transferInfo)
    }
    
    public var operationId: String {
        return dto.operationMultipleId
    }
    
    public var actions: [BizumMoneyRequestMultiActionEntity] {
        return dto.listValidationResponses.validationResponses.map {
            BizumMoneyRequestMultiActionEntity(id: $0.id,
                                               beneficiaryAlias: $0.beneficiaryAlias,
                                               operationId: $0.operationId,
                                               action: $0.action)
        }
    }
}
