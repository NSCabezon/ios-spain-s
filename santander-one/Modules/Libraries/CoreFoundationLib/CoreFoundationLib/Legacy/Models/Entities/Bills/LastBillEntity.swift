//
//  LastBillEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 2/20/20.
//

import Foundation
import SANLegacyLibrary

public enum LastBillType {
    case receipt
    case tax
}

public enum LastBillStatus: CaseIterable {
    case unknown
    case canceled
    case applied
    case returned
    case pendingToApply
    case pendingOfDate
    case pendingToResolve
    
    init(_ status: BillStatus) {
        switch status {
        case .canceled:
            self = .canceled
        case .applied:
            self = .applied
        case .returned:
            self = .returned
        case .pendingToApply:
            self = .pendingToApply
        case .pendingOfDate:
            self = .pendingOfDate
        case .pendingToResolve:
            self = .pendingToResolve
        case .unknown:
            self = .unknown
        }
    }
}

extension LastBillStatus {
    public var description: String {
        switch self {
        case .unknown:
            return "search_label_all"
        case .canceled:
            return "receiptsAndTaxes_label_statusAnu"
        case .applied:
            return "receiptsAndTaxes_label_statusApl"
        case .returned:
            return "receiptsAndTaxes_label_statusDev"
        case .pendingToApply:
            return "receiptsAndTaxes_label_statusPap"
        case .pendingOfDate:
            return "receiptsAndTaxes_label_statusPtf"
        case .pendingToResolve:
            return "receiptsAndTaxes_label_statusPtr"
        }
    }
    
    public var trackName: String {
        switch self {
        case .unknown:
            return "todos"
        case .canceled:
            return "anulado"
        case .applied:
            return "aplicado"
        case .returned:
            return "devuelto"
        case .pendingToApply:
            return "pdte_aplicar"
        case .pendingOfDate:
            return "pdte_fecha"
        case .pendingToResolve:
            return "pdte_resolver"
        }
    }
}

public final class LastBillEntity: DTOInstantiable {
    public var dto: BillDTO
    
    public init(_ dto: BillDTO) {
        self.dto = dto
    }
    
    public var name: String {
        return dto.name
    }
    
    public var holder: String {
        return dto.holder
    }
    
    public var amountWithSymbol: AmountEntity {
        guard let value = dto.amount.value else {
            return AmountEntity(self.dto.amount)
        }
        var amount = dto.amount
        if status == .returned {
            amount.value = abs(value)
        } else {
            amount.value = -abs(value)
        }
        return AmountEntity(amount)
    }
    
    public var amount: AmountEntity {
        return AmountEntity(self.dto.amount)
    }
    
    public var status: LastBillStatus {
        return LastBillStatus(self.dto.status)
    }
    
    public var billType: LastBillType {
        guard self.dto.idban.count > 6 else { return .tax }
        return .receipt
    }
    
    public var linkedAccount: String {
        return dto.debtorAccount
    }
    
    public var issuerCode: String {
        return dto.code
    }
    
    public var paymentDate: Date {
        return self.dto.pagDate
    }
    
    public var expirationDate: Date {
        return self.dto.expirationDate
    }
}
