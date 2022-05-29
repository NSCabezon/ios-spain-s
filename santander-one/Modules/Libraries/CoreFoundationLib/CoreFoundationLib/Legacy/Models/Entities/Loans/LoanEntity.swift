//
//  LoanEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import SANLegacyLibrary
import CoreDomain

public final class LoanEntity {
    public let representable: LoanRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Loan"
    
    public init(_ dto: LoanDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: LoanDTO {
        precondition((representable as? LoanDTO) != nil)
        return representable as! LoanDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: LoanRepresentable) {
        self.representable = representable
    }
    
    public var productIdentifier: String {
        return (representable.productIdentifier ?? "") + (representable.contractDescription ?? "").trim()
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var contractDescription: String? {
        return representable.contractDescription
    }
    
    public var currentBalance: Decimal? {
        return representable.currentBalanceAmountRepresentable?.value
    }
    
    public var currentBalanceAmount: AmountEntity? {
        return representable.currentBalanceAmountRepresentable.map(AmountEntity.init)
    }
    
    public var currentBalanceCurrency: CurrencyDTO? {
        let currencyName = representable.currentBalanceAmountRepresentable?.currencyRepresentable?.currencyName ?? ""
        return CurrencyDTO.create(currencyName)
    }
    
    public var contract: ContractEntity? {
        return representable.contractRepresentable.map(ContractEntity.init)
    }
    
    public var shortContract: String {
        guard let contract = representable.contractRepresentable?.contratoPK else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }

    public var formattedContract: String {
        guard let contract = representable.contractRepresentable?.contratoPK else { return "" }
        return contract
    }
    
    public var counterValueCurrentBalanceAmount: Decimal? {
        return representable.counterCurrentBalanceAmountRepresentable?.value
    }
    
    public var ownershipTypeDesc: OwnershipTypeDesc? {
        let typeOwnershipDesc = representable.typeOwnershipDesc
        return OwnershipTypeDesc.findBy(type: typeOwnershipDesc)
    }
    
    public var contractDisplayNumber: String? {
        return representable.contractDisplayNumber
    }
}

extension LoanEntity: GlobalPositionProduct {}

extension LoanEntity: Equatable, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(alias)
        hasher.combine(currentBalance)
        hasher.combine(ownershipTypeDesc)
        hasher.combine(contractDescription)
    }
    
    public static func == (lhs: LoanEntity, rhs: LoanEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
