//
//  GetSavingTransactionsUseCase.swift
//  SavingProducts
//
//  Created by Jose Camallonga on 22/2/22.
//

import Foundation
import CoreDomain
import OpenCombine

protocol GetSavingTransactionsUseCase {
    func fetch(params: SavingTransactionParams) -> AnyPublisher<SavingTransactionsResponseRepresentable, Error>
}

struct DefaultGetSavingTransactionsUseCase {
    private let repository: SavingTransactionsRepository
    
    init(repository: SavingTransactionsRepository) {
        self.repository = repository
    }
}

extension DefaultGetSavingTransactionsUseCase: GetSavingTransactionsUseCase {
    func fetch(params: SavingTransactionParams) -> AnyPublisher<SavingTransactionsResponseRepresentable, Error> {
        return repository.getTransactions(params)
    }
}

// MARK: - SavingTransactionParamsRepresentable
struct SavingTransactionParams: SavingTransactionParamsRepresentable {
    let accountID: String
    let type: String?
    let contract: ContractRepresentable?
    let fromBookingDate: Date?
    let toBookingDate: Date?
    let offset: String?
    
    init(accountID: String,
         type: String? = nil,
         contract: ContractRepresentable? = nil,
         fromBookingDate: Date? = nil,
         toBookingDate: Date? = nil,
         offset: String? = nil) {
        self.accountID = accountID
        self.type = type
        self.contract = contract
        self.fromBookingDate = fromBookingDate
        self.toBookingDate = toBookingDate
        self.offset = offset
    }
}
