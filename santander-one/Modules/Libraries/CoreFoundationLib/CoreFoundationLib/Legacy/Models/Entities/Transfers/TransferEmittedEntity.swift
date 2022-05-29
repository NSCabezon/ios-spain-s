//
//  TransferEmittedEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 12/20/19.
//

import Foundation
import SANLegacyLibrary

public final class TransferEmittedEntity: DTOInstantiable, TransferEntityProtocol {
    
    public enum TransferEmittedType {
        case sepa, noSepa
    }
    
    public let dto: TransferEmittedDTO
    public var instantPaymentId: String?
    
    public init(_ dto: TransferEmittedDTO) {
        self.dto = dto
    }
    
    public var beneficiary: String? {
        return dto.beneficiary
    }
    
    public var executedDate: Date? {
        return dto.executedDate
    }
    
    public var concept: String? {
        return dto.concept
    }
    
    public var transferType: KindOfTransfer {
        return .emitted
    }
    
    public var amountEntity: AmountEntity {
        guard let amount = dto.amount else {
            return AmountEntity(value: 0)
        }
        return AmountEntity(amount)
    }
    
    public var type: TransferEmittedType {
        let currencyType = dto.amount?.currency?.currencyType
        let transferType = dto.transferType
        if currencyType == .eur,
            transferType != TransfersType.INTERNATIONAL_NO_SEPA.rawValue {
            return .sepa
        } else {
            return .noSepa
        }
    }
}

extension TransferEmittedEntity: Equatable {
    public static func == (lhs: TransferEmittedEntity, rhs: TransferEmittedEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension TransferEmittedEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(beneficiary)
        hasher.combine(concept)
        hasher.combine(executedDate)
        hasher.combine(type)
    }
}

public enum KindOfTransfer {
    case emitted
    case received
}

public protocol TransferEntityProtocol {
    var executedDate: Date? { get }
    var beneficiary: String? { get }
    var concept: String? { get }
    var amountEntity: AmountEntity { get }
    var transferType: KindOfTransfer { get }
    var instantPaymentId: String? { get }
}
