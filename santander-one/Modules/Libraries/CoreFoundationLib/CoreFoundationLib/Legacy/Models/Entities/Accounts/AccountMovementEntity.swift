//
//  AccountMovementEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 02/09/2020.
//

import Foundation
import SANLegacyLibrary

public struct AccountMovementEntity: DTOInstantiable {
    
    public let dto: AccountMovementDTO
    
    public init(_ dto: AccountMovementDTO) {
        self.dto = dto
    }
    
    public var productIdentifier: String? {
        return self.dto.movementId
    }
    
    public var amount: AmountEntity {
        return AmountEntity(self.dto.amountDTO)
    }

    public var balance: AmountEntity {
        return AmountEntity(self.dto.balanceDTO)
    }
}

extension AccountMovementEntity: EasyPayTransaction {
    public var description: String? {
        return self.dto.description
    }
    
    public var operationDate: Date? {
        return self.dto.operationDate
    }
}

extension AccountMovementEntity: Hashable {
    public static func == (lhs: AccountMovementEntity, rhs: AccountMovementEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(productIdentifier)
        hasher.combine(balance.value)
        hasher.combine(amount.value)
        hasher.combine(operationDate)
        hasher.combine(description)
    }
}
