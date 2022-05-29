//
//  StandingOrderDataEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 13/7/21.
//
import SANLegacyLibrary

public final class StandingOrderEntity {
    private let dto: StandingOrderDTO
    public let account: AccountEntity
    
    public init(dto: StandingOrderDTO, account: AccountEntity) {
        self.dto = dto
        self.account = account
    }
    
    public var subject: String? {
        dto.subject
    }
    
    public var amount: AmountEntity {
        AmountEntity(value: dto.paymentAmount?.amount ?? 0)
    }
    
    public var periodicity: StandingOrderPeriodicityType {
        dto.periodicity ?? .none
    }
    
    public var startDate: String {
        return dto.startDate ?? ""
    }
    
    public var orderType: StandingOrderType? {
        return dto.orderType
    }
    
    public var beneficiary: String? {
        return dto.creditorName
    }
    
    public var accountId: String {
        return dto.accountId
    }
}

extension StandingOrderEntity: ScheduledTransferRepresentable {
    public var transferAmount: AmountEntity? {
        amount
    }
    
    public var transfer: TransferScheduledDTO? {
        nil
    }
    
    public var concept: String? {
        subject
    }
    
    public var isPeriodic: Bool {
        periodicity != .fixed && periodicity != .none
    }
    
    public var currency: String? {
        amount.currencyTrack
    }
    
    public var periodicityString: String? {
        switch periodicity {
        case .fixed :
            return "deliveryDetails_label_timely"
        case .monthly :
            return "generic_label_monthly"
        case .halfYear :
            return "generic_label_biannual"
        case .weekly :
            return "generic_label_weekly"
        case .annualy :
            return "generic_label_annual"
        case .bimonth :
            return "generic_label_bimonthly"
        case .none :
            return ""
        }
    }
    
    public var endDate: Date? {
        nil
    }
    
    public var emmitedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withDashSeparatorInDate, .withFullDate]
        return formatter.date(from: startDate)
    }
}
