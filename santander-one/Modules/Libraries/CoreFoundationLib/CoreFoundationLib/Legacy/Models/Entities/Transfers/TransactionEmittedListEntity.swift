//
//  TransactionEmittedListEntity.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/20/19.
//

import SANLegacyLibrary

public final class TransactionEmittedListEntity: DTOInstantiable {
    
    public let dto: TransferEmittedListDTO
    
    public init(_ dto: TransferEmittedListDTO) {
        self.dto = dto
    }
    
    public var transfers: [TransferEmittedEntity] {
        return dto.transactionDTOs.map {TransferEmittedEntity($0)}
    }
    
    public var pagination: PaginationEntity {
        return PaginationEntity(dto.paginationDTO)
    }
}
