//
//  PensionEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class PensionEntity {
    public let representable: PensionRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Pension"
    
    public init(_ dto: PensionDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: PensionDTO {
        precondition((representable as? PensionDTO) != nil)
        return representable as! PensionDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: PensionRepresentable) {
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
    
    public func isAllianz(filterWith allianzProducts: [ProductAllianz]) -> Bool {
        guard !allianzProducts.isEmpty else { return false }
        return allianzProducts
            .filter { $0.type == self.representable.productSubtypeRepresentable?.productType }
            .contains { (productAllianz) -> Bool in
                guard
                    let fromSubtypeString = productAllianz.fromSubtype,
                    let fromSubtype = Int(fromSubtypeString),
                    let toSubtypeString = productAllianz.toSubtype,
                    let toSubtype = Int(toSubtypeString),
                    let productSubtypeString = self.representable.productSubtypeRepresentable?.productSubtype,
                    let productSubtype = Int(productSubtypeString)
                    else { return false }
                return fromSubtype <= productSubtype && productSubtype <= toSubtype
        }
    }
    
    public var counterValueAmount: Decimal? {
        return representable.counterValueAmountRepresentable?.value
    }
    
    public var amount: AmountEntity? {
        return representable.valueAmountRepresentable.map(AmountEntity.init)
    }
}

extension PensionEntity: GlobalPositionProduct {}
