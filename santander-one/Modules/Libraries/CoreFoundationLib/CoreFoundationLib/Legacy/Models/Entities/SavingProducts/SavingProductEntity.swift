//
//  SavingProductEntity.swift
//  Models
//
//  Created by Jose Camallonga on 11/11/21.
//
import SANLegacyLibrary
import CoreDomain

public final class SavingProductEntity: DTOInstantiable, Equatable {
    public let representable: SavingProductRepresentable
    public var isVisible: Bool = true
    public let productId: String = "SavingProduct"
    
    public init(_ dto: SavingProductDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: SavingProductDTO {
        precondition((representable as? SavingProductDTO) != nil)
        return representable as! SavingProductDTO
    }
    
    // swiftlint:enable force_cast
    public init(_ representable: SavingProductRepresentable) {
        self.representable = representable
    }
    
    public var accountId: String? {
        return representable.accountId
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var contractNumber: String? {
        return representable.contractRepresentable?.contractNumber
    }
    
    public var shortContract: String {
        guard let contract = representable.contractRepresentable?.formattedValue else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    public var counterValueAmount: Decimal? {
        return representable.counterValueAmountRepresentable?.value
    }
    
    public static func == (lhs: SavingProductEntity, rhs: SavingProductEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension SavingProductEntity: GlobalPositionProduct {}

extension SavingProductEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}
