//
//  EasyPayAmortizationEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 06/05/2020.
//

import SANLegacyLibrary
import CoreDomain

public struct EasyPayAmortizationEntity {
    public let dto: EasyPayAmortizationDTO
    
    public init(_ dto: EasyPayAmortizationDTO) {
        self.dto = dto
    }
    
    public var amortizations: [AmortizationEntity] {
        let amortizationsDto = dto.amortizations ?? []
        return amortizationsDto.map({ amortizationDto -> AmortizationEntity in
            return AmortizationEntity(amortizationDto)
        })
    }
    
    public init(from entity: EasyPayCurrentFeeDataEntity) {
        var dto = EasyPayAmortizationDTO()
        
        var amort = AmortizationDTO()
        if let interestsAmount = entity.interestsAmount {
            amort.interestAmount = AmountDTO(value: Decimal(interestsAmount),
                                             currency: entity.currency)
        }
        if let totalAmount = entity.totalAmount {
            amort.totalFeeAmount = AmountDTO(value: Decimal(totalAmount),
                                             currency: entity.currency)
        }
        amort.nextAmortizationDate = entity.settlementDate
        
        if let months = entity.totalMonths {
            dto.amortizations = (0..<months).map { _ in amort }
        }
        self.dto = dto
    }
    
    public init(representable: FeesInfoRepresentable, settlementDate: Date?) {
        var dto = EasyPayAmortizationDTO()
        let currencyType: CurrencyType = CurrencyType(rawValue: representable.currency) ?? CoreCurrencyDefault.default
        let currencyDTO = CurrencyDTO(currencyName: representable.currency, currencyType: currencyType)
        var amort = AmortizationDTO()
        if let interestsAmount = representable.interests {
            amort.interestAmount = AmountDTO(value: Decimal(interestsAmount),
                                             currency: currencyDTO)
        }
        if let totalAmount = representable.totalImport {
            amort.totalFeeAmount = AmountDTO(value: Decimal(totalAmount),
                                             currency: currencyDTO)
        }
        amort.nextAmortizationDate = settlementDate
        
        if let months = representable.totalMonths {
            dto.amortizations = (0..<months).map { _ in amort }
        }
        self.dto = dto
    }
}
