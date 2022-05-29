//
//  EcommerceOperationEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 03/03/2021.
//

import SANLegacyLibrary

public final class EcommerceOperationDataEntity: DTOInstantiable {
    
    public let dto: EcommerceOperationDataDTO
    
    public init(_ dto: EcommerceOperationDataDTO) {
        self.dto = dto
    }
    
    public var cardNumber: String {
        return dto.cardNumber
    }
    
    public var commerceName: String {
        return dto.commerce
    }
    
    public var amount: AmountEntity {
        let ecommerceAmount = self.dto.amount
        let currency = self.dto.currency
        let amountDTO = AmountDTO(value: Decimal(ecommerceAmount), currency: CurrencyDTO.create(currency))
        return AmountEntity(amountDTO)
    }
    
    public var cardName: String {
        return dto.cardName
    }
    
    public var status: String {
        return dto.state
    }
}
