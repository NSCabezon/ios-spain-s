//
//  SavingProductDTO.swift
//  SANLegacyLibrary
//
//  Created by Jose Camallonga on 10/11/21.
//

import CoreDomain

public struct SavingProductDTO: BaseProductDTO {
    public var accountId: String?
    public var alias: String?
    public var identification: String?
    public var accountSubType: String?
    public var currentBalance: AmountDTO?
    public var balanceIncludedPending: AmountDTO?
    public var interestRate: String?
    public var interestRateLink: InterestRateLinkDTO?
    public var contract: ContractDTO?
    public var currency: CurrencyDTO?
    public var ownershipTypeDesc: OwnershipTypeDesc?
    public var counterValueAmount: AmountDTO?
    
    public init() {}
}

public struct InterestRateLinkDTO: InterestRateLinkRepresentable, Codable {
    public let title: String
    public let url: String

    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

extension SavingProductDTO: SavingProductRepresentable {
    public var currentBalanceRepresentable: AmountRepresentable? {
        return currentBalance
    }
    public var balanceIncludedPendingRepresentable: AmountRepresentable? {
        return balanceIncludedPending
    }
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var counterValueAmountRepresentable: AmountRepresentable? {
        return counterValueAmount
    }
    public var interestRateLinkRepresentable: InterestRateLinkRepresentable? {
        return interestRateLink
    }
}
