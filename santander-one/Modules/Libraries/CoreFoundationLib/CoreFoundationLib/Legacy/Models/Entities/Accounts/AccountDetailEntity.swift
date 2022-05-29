//
//  AccountDetailEntity.swift
//  Accounts
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import SANLegacyLibrary

public final class AccountDetailEntity: DTOInstantiable {
    
    public let dto: AccountDetailDTO
    
    public init(_ dto: AccountDetailDTO) {
        self.dto = dto
    }
    
    public var withholdingAmount: AmountEntity? {
        guard let withholdingAmount = dto.withholdingAmount else { return nil }
        return AmountEntity(withholdingAmount)
    }
    
    public var mainBalance: AmountEntity? {
        guard let mainBalance = dto.mainBalance else { return nil }
        return AmountEntity(mainBalance)
    }
    
    public var authorizedBalance: AmountEntity? {
        guard let authorizedBalance = dto.authorizedBalance else { return nil }
        return AmountEntity(authorizedBalance)
    }
    
    public var description: String? {
        guard let description = dto.description else { return nil }
        return description
    }
    
    public var accountId: String? {
        guard let accountId = dto.accountId else { return nil }
        return accountId
    }
    
    public var bicCode: String? {
        guard let bicCode = dto.bicCode else { return nil }
        return bicCode
    }
    
    public var mainItem: Bool? {
        guard let mainItem = dto.mainItem else { return nil }
        return mainItem
    }
    
    public var interestRate: String? {
        guard let interestRate = dto.interestRate else { return nil}
        return interestRate
    }
    
    public var currentBalance: AmountEntity? {
        guard let currentBalance = dto.balance else { return nil }
        return AmountEntity(currentBalance)
    }
    
    public var overdraft: AmountEntity? {
        guard let overdraft = dto.overdraftAmount else { return nil }
        return AmountEntity(overdraft)
    }
    
    public var holder: String? {
        guard let holder = dto.holder else { return nil }
        return holder
    }
    
    public var earningsAmount: AmountEntity? {
        guard let earningsAmount = dto.earningsAmount else { return nil }
        return AmountEntity(earningsAmount)
    }
}
