//
//  TransactionReceivedListEntity.swift
//  Models
//
//  Created by alvola on 18/05/2020.
//

import SANLegacyLibrary

public final class TransactionReceivedListEntity {
    private let dto: AccountTransactionsListDTO
    private let accountDTO: AccountDTO
    
    public init(_ dto: AccountTransactionsListDTO, accountDTO: AccountDTO) {
        self.dto = dto
        self.accountDTO = accountDTO
    }
    
    public var transfers: [TransferReceivedEntity] {
        return dto.transactionDTOs.map { TransferReceivedEntity($0, accountDTO: self.accountDTO) }
    }
    
    public var pagination: PaginationEntity {
        return PaginationEntity(dto.pagination)
    }
}
