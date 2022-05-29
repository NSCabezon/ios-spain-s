//
//  CardSettlementMovementEntity.swift
//  Models
//
//  Created by Laura González on 13/10/2020.
//

import SANLegacyLibrary

final public class CardSettlementMovementEntity: DTOInstantiable {
    public let dto: CardSettlementMovementDTO
    
    public init(_ dto: CardSettlementMovementDTO) {
        self.dto = dto
    }
    
    public var movementDate: Date? {
        return dto.operationDate
    }
    
    public var movementHour: String? {
        return dto.operationHour
    }
    
    public var movementAmount: Double? {
        return dto.amount
    }
    
    public var movementConcept: String? {
        return dto.concept
    }
    
    public var settlementMovement: String? {
        return dto.settlementMov
    }
}
