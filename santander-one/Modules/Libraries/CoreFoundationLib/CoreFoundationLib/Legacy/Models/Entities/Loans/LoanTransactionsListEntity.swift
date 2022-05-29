//
//  LoanTransactionListEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import SANLegacyLibrary

public final class LoanTransactionsListEntity: DTOInstantiable {
    
    public let dto: LoanTransactionsListDTO
    
    public init(_ dto: LoanTransactionsListDTO) {
        self.dto = dto
    }
    
    public var transactions: [LoanTransactionEntity] {
        return dto.transactionDTOs.map(LoanTransactionEntity.init)
    }
    
    public var pagination: PaginationEntity {
        return PaginationEntity(dto.pagination)
    }
}
