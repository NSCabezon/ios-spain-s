//
//  CardSettlementDetailEntity.swift
//  Cards
//
//  Created by David Gálvez Alonso on 07/10/2020.
//

import SANLegacyLibrary

final public class CardSettlementDetailEntity: DTOInstantiable {
    public let dto: CardSettlementDetailDTO
    
    public init(_ dto: CardSettlementDetailDTO) {
        self.dto = dto
    }
    
    public var ascriptionDate: Date? {
        return dto.ascriptionDate
    }
    
    public var startDate: Date? {
        return dto.startDate
    }
    
    public var endDate: Date? {
        return dto.endDate
    }
    
    public var totalAmount: AmountEntity {
        guard let amount = dto.totalAmount else {
            return AmountEntity(value: 0.0)
        }
        let decimal = Decimal(amount)
        return AmountEntity(AmountDTO(value: decimal, currency: .create(CoreCurrencyDefault.default)))
    }
    
    public var errorCode: Int? {
        return dto.errorCode
    }
    
    public var emptyMovements: Bool {
        return errorCode == 204
    }

    public var extractNumber: Int? {
        return dto.extractNumber
    }
}
