//
//  FundsEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class FundEntity {
    public let representable: FundRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Fund"
    
    public init(_ dto: FundDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: FundDTO {
        precondition((representable as? FundDTO) != nil)
        return representable as! FundDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: FundRepresentable) {
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
        guard let value = representable.valueAmountRepresentable?.value else { return nil }
        return String(describing: value)
    }
    
    public var shortContract: String {
        guard let contract = representable.contractDescription else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    public var isAllianz: Bool {
        let productSubtype = representable.productSubtypeRepresentable
        return productSubtype?.productType == "831" && productSubtype?.productSubtype == "002"
    }
    
    public var counterValueAmount: Decimal? {
        return representable.countervalueAmountRepresentable?.value
    }
    
    public var amount: AmountEntity? {
        return representable.valueAmountRepresentable.map(AmountEntity.init)
    }
}

extension FundEntity: GlobalPositionProduct {}
