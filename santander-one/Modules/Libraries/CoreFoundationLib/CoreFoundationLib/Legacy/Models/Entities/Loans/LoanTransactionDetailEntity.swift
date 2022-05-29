//
//  LoanTransactionDetailEntity.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 31/8/21.
//

import SANLegacyLibrary
import CoreDomain

public final class LoanTransactionDetailEntity: DTOInstantiable {

    public let dto: LoanTransactionDetailDTO

    public init(_ dto: LoanTransactionDetailDTO) {
        self.dto = dto
    }
    
    public var capital: AmountEntity? {
        return dto.capital.map(AmountEntity.init)
    }
    
    public var interest: AmountEntity? {
        return dto.interestAmount.map(AmountEntity.init)
    }
    
    public var recipientAccountNumber: String? {
        return dto.recipientAccountNumber
    }
    
    public var recipientData: String? {
        return dto.recipientData
    }
    
    public var representable: LoanTransactionDetailRepresentable {
        return self
    }
}

extension LoanTransactionDetailEntity: LoanTransactionDetailRepresentable {
    public var feeRepresentable: AmountRepresentable? {
        return dto.feeAmount
    }
    
    public var pendingAmountRepresentable: AmountRepresentable? {
        return dto.pendingAmount
    }
    
    public var capitalRepresentable: AmountRepresentable? {
        return capital
    }
    
    public var interestRepresentable: AmountRepresentable? {
        return interest
    }
}
