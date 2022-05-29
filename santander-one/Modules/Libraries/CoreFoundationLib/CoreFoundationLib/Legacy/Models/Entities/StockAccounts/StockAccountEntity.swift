//
//  StockAccountEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class StockAccountEntity {
    public let representable: StockAccountRepresentable
    public var isVisible: Bool = true
    public var productId: String = "StockAccount"
    
    public init(_ representable: StockAccountRepresentable) {
        self.representable = representable
    }
    
    public init(_ dto: StockAccountDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: StockAccountDTO {
        precondition((representable as? StockAccountDTO) != nil)
        return representable as! StockAccountDTO
    }
    // swiftlint:enable force_cast
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var detailUI: String? {
        guard let contractDescription = representable.contractDescription else { return nil }
        let descTrim = contractDescription.replace(" ", "")
        if descTrim.count != 20 {
            return descTrim
        }
        return "\(descTrim.substring(0, 4) ?? "") \(descTrim.substring(4, 8) ?? "") \(descTrim.substring(8, 10) ?? "") \(descTrim.substring(10, 20) ?? "")"
    }
    
    public var amountUI: String? {
        guard let value = representable.valueAmountRepresentable?.value else { return nil }
        return String(describing: value)
    }
    
    public var amount: AmountEntity? {
        return representable.valueAmountRepresentable.map(AmountEntity.init)
    }
    
    public var amountFormatted: NSAttributedString? {
//        MoneyDecorator(AmountEntity(dto: $0.dto.valueAmount!), font: UIFont.santander(family: .text, size: 20.0)).getFormatedCurrency()
        return nil
    }
    
    public var shortContract: String {
        guard let contract = representable.contractDescription else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    public var counterValueAmount: Decimal? {
        return representable.countervalueAmountRepresentable?.value
    }
}

extension StockAccountEntity: GlobalPositionProduct {}
