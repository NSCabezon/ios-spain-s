//
//  LoanDetailEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 09/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class LoanDetailEntity {
    
    public let representable: LoanDetailRepresentable
    
    public init(_ dto: LoanDetailDTO) {
        self.representable = dto
    }
    
    public init(_ representable: LoanDetailRepresentable) {
        self.representable = representable
    }
    
    public var holder: String? {
        return representable.holder
    }
    
    public var linkedAccount: String? {
        return representable.linkedAccountDesc
    }
    
    public var openingDate: Date? {
        return representable.openingDate
    }
    
    public var initialDueDate: Date? {
        return representable.initialDueDate
    }
    
    public var currentDueDate: Date? {
        return representable.currentDueDate
    }
    
    public var initialAmount: AmountEntity? {
        return representable
            .initialAmountRepresentable
            .map(AmountEntity.init)
    }

    public var interestRate: String? {
        return representable.interestType
    }

    public var referenceRate: String? {
        return representable.interestTypeDesc
    }
    
    public var feePeriod: String? {
        return representable.feePeriodDesc
    }
    
    public var revocable: Bool? {
        return representable.revocable
    }
    
    public var amortizable: Bool? {
        return representable.amortizable
    }
    
    public var nextInstallmentDate: Date? {
        return representable.nextInstallmentDate
    }
    
    public var currentInterestAmount: String? {
        return representable.currentInterestAmount
    }
    
    public var lastOperationDate: Date? {
        return representable.lastOperationDate
    }

}
