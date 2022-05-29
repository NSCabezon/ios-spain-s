//
//  TransferSubTypeCommission.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 03/02/2020.
//

import Foundation
import SANLegacyLibrary

public enum TransferSubType {
    
    case urgent
    case instant
    case standard
    
    init(_ dto: TransferSubTypeDTO) {
        switch dto {
        case .urgent: self = .urgent
        case .instant: self = .instant
        case .standard: self = .standard
        }
    }
}

extension TransferSubType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .urgent: return "sendMoney_label_expressDelivery"
        case .instant: return "sendMoney_label_immediateSend"
        case .standard: return "sendMoney_label_standardSent"
        }
    }
    
    public var string: String {
        switch self {
        case .standard: return "standard"
        case .instant: return "immediate"
        case .urgent: return "urgent"
        }
    }
}

public struct TransferSubTypeCommissionEntity: DTOInstantiable {
    
    public let dto: TransferSubTypeCommissionDTO
    
    public init(_ dto: TransferSubTypeCommissionDTO) {
        self.dto = dto
    }
    
    public var commissions: [TransferSubType: AmountEntity?] {
        let commissions = dto.commissions.map { subtype, amount in
            (TransferSubType(subtype), amount.map(AmountEntity.init))
        }
        return Dictionary(uniqueKeysWithValues: commissions)
    }
    
    public var taxes: [TransferSubType: AmountEntity?]? {
        guard let tax = dto.taxes else { return nil }
        let taxes = tax.map { subtype, amount in
            (TransferSubType(subtype), amount.map(AmountEntity.init))
        }
        return Dictionary(uniqueKeysWithValues: taxes)
    }
    
    public var total: [TransferSubType: AmountEntity?]? {
        guard let total = dto.total else { return nil }
        let totalList = total.map { subtype, amount in
            (TransferSubType(subtype), amount.map(AmountEntity.init))
        }
        return Dictionary(uniqueKeysWithValues: totalList)
    }
    
    public var transferPackage: [TransferSubType: TransferPackage?]? {
        guard let transferPackage = dto.transferPackage else { return nil }
        let transferPackageList = transferPackage.map { subtype, package in
            (TransferSubType(subtype), package)
        }
        return Dictionary(uniqueKeysWithValues: transferPackageList)
    }
}
