//
//  ScheduledTransferEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import SANLegacyLibrary

public class ScheduledTransferEntity {
    
    public var transferDTO: TransferScheduledDTO
    
    public init(dto: TransferScheduledDTO) {
        self.transferDTO = dto
    }
    
    public var concept: String? {
        return transferDTO.concept
    }
    
    public var amount: AmountEntity? {
        guard let amount = transferDTO.transferAmount else {
            return AmountEntity(value: 0)
        }
        return AmountEntity(amount)
    }
    
    public var numberOrderHeader: String? {
        return transferDTO.numberOrderHeader
    }
    
    public var transferType: String? {
        return transferDTO.typeTransfer
    }
    
    public var isPeriodic: Bool {
         return transferDTO.typeTransfer?.lowercased() == "p"
    }
    
    var isScheduledTransfer: Bool {
        return transferDTO.typeTransfer?.lowercased() != "p"
    }
    
    public var dateStartValidity: Date? {
        return transferDTO.dateStartValidity
    }
    
    public var endDate: Date? {
        return transferDTO.dateEndValidity
    }
    
    public var periodicalType: PeriodicalTransferType? {
        guard let periodicalType = transferDTO.periodicalType else { return nil }
        switch periodicalType {
        case .none, .weekly, .bimonthly, .annual:
            return nil
        case .monthly:
            return .monthly
        case .trimestral:
            return .trimestral
        case .semiannual:
            return .semiannual
        }
    }
}

public enum PeriodicalTransferType {
    case monthly
    case trimestral
    case semiannual
}

extension ScheduledTransferEntity: ScheduledTransferRepresentable {
    public var transferAmount: AmountEntity? {
        return self.amount
    }

    public var emmitedDate: Date? {
        return self.dateStartValidity
    }
    
    public var transfer: TransferScheduledDTO? {
        self.transferDTO
    }
    
    public var currency: String? {
        transferDTO.transferAmount?.currency?.currencyName
    }
    
    public var periodicityString: String? {
        switch periodicalType {
        case .monthly?:
            return "summary_label_monthly"
        case .trimestral?:
            return "summary_label_quarterly"
        case .semiannual?:
            return "summary_label_sixMonthly"
        default:
            return nil
        }
    }
}

public protocol ScheduledTransferRepresentable {
    var transfer: TransferScheduledDTO? { get }
    var concept: String? { get }
    var isPeriodic: Bool { get }
    var periodicityString: String? { get }
    var currency: String? { get }
    var endDate: Date? { get }
    var emmitedDate: Date? { get }
    var transferAmount: AmountEntity? { get }
}

public extension ScheduledTransferRepresentable {
    var transferEntity: TransferScheduledEntity? {
        guard let dto = self.transfer else { return nil }
        return TransferScheduledEntity(dto: dto)
    }
}
