//
//  CardDetailEntity.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 08/12/2019.
//

import SANLegacyLibrary
import CoreDomain

final public class CardDetailEntity: DTOInstantiable {
    public let dto: CardDetailDTO
    public var clientName: String?
    public var cardDataDTO: CardDataDTO?
    public var representable: CardDetailRepresentable
    
    public init(_ dto: CardDetailDTO) {
        self.dto = dto
        self.representable = dto
    }
    
    public init(_ dto: CardDetailDTO, cardDataDTO: CardDataDTO?, clientName: String) {
        self.dto = dto
        self.clientName = clientName
        self.cardDataDTO = cardDataDTO
        self.representable = dto
    }
    
    public var holder: String? {
        return dto.holder
    }
        
    public var linkedAccountShort: String {
        guard let linkedChargeAccount = dto.linkedAccountDescription else { return "****" }
        return "*" + (linkedChargeAccount.substring(linkedChargeAccount.count - 4) ?? "*")
    }
    
    public var isCardBeneficiary: Bool {
        if let beneficiary = self.dto.beneficiary, clientName?.trim() == beneficiary.trim() {
            return true
        }
        return false
    }
    
    public var cardBeneficiary: String? {
        return dto.beneficiary
    }
    
    public var expirationDate: Date? {
        return dto.expirationDate
    }
    
    public var linkedAccount: String? {
        return dto.linkedAccountDescription
    }
    
    public var paymentModality: String? {
        return nil
    }

    public var status: String? {
        return dto.statusType
    }

    public var currency: String? {
        return dto.currency
    }

    public var creditCardAccountNumber: String? {
        return dto.creditCardAccountNumber
    }

    public var insurance: String? {
        return dto.insurance
    }

    public var interestRate: String? {
        return dto.interestRate
    }

    public var withholdings: AmountEntity? {
        guard let withholdings = dto.withholdings else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(withholdings)
    }

    public var previousPeriodInterest: AmountEntity? {
        guard let previousPeriodInterest = dto.previousPeriodInterest else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(previousPeriodInterest)
    }

    public var minimumOutstandingDue: AmountEntity? {
        guard let minimumOutstandingDue = dto.minimumOutstandingDue else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(minimumOutstandingDue)
    }

    public var currentMinimumDue: AmountEntity? {
        guard let currentMinimumDue = dto.currentMinimumDue else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(currentMinimumDue)
    }

    public var totalMinimumRepaymentAmount: AmountEntity? {
        guard let totalMinimumRepaymentAmount = dto.totalMinimumRepaymentAmount else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(totalMinimumRepaymentAmount)
    }

    public var lastStatementDate: Date? {
        return dto.lastStatementDate
    }

    public var nextStatementDate: Date? {
        return dto.nextStatementDate
    }

    public var actualPaymentDate: Date? {
        return dto.actualPaymentDate
    }
}
