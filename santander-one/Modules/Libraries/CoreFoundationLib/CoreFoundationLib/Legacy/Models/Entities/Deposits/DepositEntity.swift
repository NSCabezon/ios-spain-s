//
//  DepositEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class DepositEntity {
    public let representable: DepositRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Deposit"
    
    public init(_ dto: DepositDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: DepositDTO {
        precondition((representable as? DepositDTO) != nil)
        return representable as! DepositDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: DepositRepresentable) {
        self.representable = representable
    }
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var detailUI: String? {
        return representable.contractDescription?.trim()
    }
    
    public var amountUI: String? {
        guard let value = representable.balanceRepresentable?.value else { return nil }
        return String(describing: value)
    }
    
    public var shortContract: String {
        guard let contract = representable.contractDescription else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    public var counterValueCurrentBalance: Decimal? {
        return self.representable.countervalueCurrentBalanceRepresentable?.value
    }
    
    public var amount: AmountEntity? {
        return self.representable.balanceRepresentable.map(AmountEntity.init)
    }
}


extension DepositEntity: GlobalPositionProduct {}
