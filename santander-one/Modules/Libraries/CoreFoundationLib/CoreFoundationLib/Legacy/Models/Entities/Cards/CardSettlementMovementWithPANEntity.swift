//
//  CardSettlementMovementWithPANEntity.swift
//  Models
//
//  Created by Laura González on 22/10/2020.
//

import SANLegacyLibrary

final public class CardSettlementMovementWithPANEntity: DTOInstantiable {
    public let dto: CardSettlementMovementWithPANDTO
    
    public init(_ dto: CardSettlementMovementWithPANDTO) {
        self.dto = dto
    }
    
    public var PAN: String? {
        return dto.pan?.trim()
    }
    
    public var movements: [CardSettlementMovementEntity]? {
        guard let movementsDTO = dto.transactions, movementsDTO.count > 0 else { return nil }
        let movements = movementsDTO.map { CardSettlementMovementEntity($0.self) }
        return movements
    }
}
