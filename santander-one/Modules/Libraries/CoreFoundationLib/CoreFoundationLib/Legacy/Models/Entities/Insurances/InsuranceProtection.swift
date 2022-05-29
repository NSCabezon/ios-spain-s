//
//  InsuranceProtection.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class InsuranceProtectionEntity {
    public let representable: InsuranceRepresentable
    public var isVisible: Bool = true
    public var productId: String = "InsuranceProtection"
    
    // swiftlint:disable force_cast
    public var dto: InsuranceDTO {
        precondition((representable as? InsuranceDTO) != nil)
        return representable as! InsuranceDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: InsuranceRepresentable) {
        self.representable = representable
    }
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var alias: String? {
        return representable.contractDescription?.trim().camelCasedString
    }
    
    public var detailUI: String? {
        guard let reference = representable.referenciaExterna,
                !reference.isEmpty else { return representable.descIdPoliza }
        return reference.trim()
    }
    
    public var amountUI: String? {
        return nil
    }
}

extension InsuranceProtectionEntity: GlobalPositionProduct {}
