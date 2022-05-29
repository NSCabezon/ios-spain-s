//
//  AmortizationEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 24/12/2020.
//

import Foundation
import SANLegacyLibrary

public struct AmortizationEntity {
    public let dto: AmortizationDTO
    
    public init(_ dto: AmortizationDTO) {
        self.dto = dto
    }
    
    public var nextAmortizationDate: Date? {
        return dto.nextAmortizationDate
    }
    
    public var interestAmount: AmountEntity? {
        guard let interestAmount = dto.interestAmount else { return nil }
        return AmountEntity(interestAmount)
    }
    
    public var totalFeeAmount: AmountEntity? {
        guard let totalFeeAmount = dto.totalFeeAmount else { return nil }
        return AmountEntity(totalFeeAmount)
    }
    
    public var amortizedAmount: AmountEntity? {
        guard let amortizedAmount = dto.amortizedAmount else { return nil }
        return AmountEntity(amortizedAmount)
    }
    
    public var pendingAmount: AmountEntity? {
        guard let pendingAmount = dto.pendingAmount else { return nil }
        return AmountEntity(pendingAmount)
    }
}
