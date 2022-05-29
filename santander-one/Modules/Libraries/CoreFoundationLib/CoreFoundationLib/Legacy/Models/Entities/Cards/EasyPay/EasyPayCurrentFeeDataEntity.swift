//
//  EasyPayCurrentFeeData.swift
//  Models
//
//  Created by Luis Escámez Sánchez on 15/12/2020.
//

import SANLegacyLibrary

public struct EasyPayCurrentFeeDataEntity {
    
    public let dto: FeesInfoDTO
    public var settlementDate: Date?
    public let totalMonths: Int?
    
    public var feeAmount: Double? {
        return dto.feeImport
    }
    public var comission: Int? {
        return dto.comission
    }
    public var interestsAmount: Double? {
        return dto.interests
    }
    public var tae: Double? {
        return dto.taeImport
    }
    public var totalAmount: Double? {
        return dto.totalImport
    }
    
    public var currency: CurrencyDTO {
        let currencyType: CurrencyType = CurrencyType(rawValue: dto.currency) ?? CoreCurrencyDefault.default
        return CurrencyDTO(currencyName: dto.currency, currencyType: currencyType)
    }
    
    public init(_ dto: FeesInfoDTO, settlementDate: Date?, totalMonths: Int) {
        self.dto = dto
        self.settlementDate = settlementDate
        self.totalMonths = totalMonths
    }
}
