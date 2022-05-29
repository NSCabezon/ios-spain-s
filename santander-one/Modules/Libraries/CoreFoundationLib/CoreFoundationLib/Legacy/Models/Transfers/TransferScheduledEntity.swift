import SANLegacyLibrary
import Foundation

public final class TransferScheduledEntity {
    
    public private(set) var transferDTO: TransferScheduledDTO
    
    public init(dto: TransferScheduledDTO) {
        transferDTO = dto
    }
    
    public var concept: String? {
        return transferDTO.concept
    }
    
    public var amount: AmountEntity? {
        guard let amount = transferDTO.transferAmount else { return nil }
        return AmountEntity(amount)
    }
    
    public var numberOrderHeader: String? {
        return transferDTO.numberOrderHeader
    }
    
    public var transferType: String? {
        return transferDTO.typeTransfer
    }
    
    public var initialPeriodDate: Date? {
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
    
    public var keyForPeriodicalType: String {
        guard let periodicalType = transferDTO.periodicalType else { return "summary_label_timely" }
        switch periodicalType {
        case .none, .weekly, .bimonthly, .annual:
            return "summary_label_timely"
        case .monthly:
            return "summary_label_monthly"
        case .trimestral:
            return "summary_label_quarterly"
        case .semiannual:
            return "summary_label_sixMonthly"
        }
    }
    
    public var isPeriodic: Bool {
        return transferDTO.typeTransfer?.lowercased() == "p"
    }
    
    public var periodicTrackerDescription: String {
        return isPeriodic ? "periodica" : "diferida"
    }
}
