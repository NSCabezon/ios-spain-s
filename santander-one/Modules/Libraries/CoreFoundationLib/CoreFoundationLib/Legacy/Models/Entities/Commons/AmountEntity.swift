//
//  AmountEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class AmountEntity: DTOInstantiable {
    
    public let dto: AmountDTO
    
    public init(_ dto: AmountDTO) {
        self.dto = dto
    }
    
    public init(value: Decimal, currency: CurrencyType = CoreCurrencyDefault.default) {
        self.dto = AmountDTO(value: value, currency: .create(currency))
    }
    
    public init(_ representable: AmountRepresentable) {
        let currencyType = representable.currencyRepresentable?.currencyType ?? CoreCurrencyDefault.default
        self.dto = AmountDTO(value: representable.value ?? 0.0, currency: .create(currencyType))
    }
    
    public init(value: Decimal, currencyCode: String) {
        self.dto = AmountDTO(value: value, currency: .create(currencyCode))
    }
    
    public var value: Decimal? {
        return dto.value
    }
    
    public var currency: String? {
        return dto.currency?.getSymbol()
    }
    
    public var currencyTrack: String? {
        return dto.currency?.currencyName
    }
    
    static public var empty: AmountEntity {
        return AmountEntity(value: 0.0)
    }
    
    public var changedSign: AmountEntity {
        return AmountEntity(value: -(self.dto.value ?? 0.0), currency: dto.currency?.currencyType ?? CoreCurrencyDefault.default)
    }
    
    public func divideByValue(_ valueBy: Int) -> AmountEntity? {
        guard let value = value, value != 0 else { return nil }
        return AmountEntity(value: value / Decimal(valueBy))
    }
}

extension AmountEntity: Equatable {
    public static func == (lhs: AmountEntity, rhs: AmountEntity) -> Bool {
        lhs.value == rhs.value && lhs.currency == rhs.currency
    }
}

extension AmountEntity: AmountRepresentable {
    public var currencyRepresentable: CurrencyRepresentable? {
        return dto.currency
    }
}
