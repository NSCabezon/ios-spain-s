import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class TransferScheduled {
    
    static func create(_ from: TransferScheduledDTO) -> TransferScheduled {
        return TransferScheduled(dto: from)
    }
    
    private(set) var transferDTO: TransferScheduledDTO
    
    init(dto: TransferScheduledDTO) {
        transferDTO = dto
    }
    
    lazy var entity: TransferScheduledEntity = {
        TransferScheduledEntity(dto: transferDTO)
    }()
    
    var concept: String? {
        return transferDTO.concept
    }
    
    var amount: Amount? {
        return Amount.createFromDTO(transferDTO.transferAmount)
    }
    
    var numberOrderHeader: String? {
        return transferDTO.numberOrderHeader
    }
    
    var transferType: String? {
        return transferDTO.typeTransfer
    }
    
    var initialPeriodDate: Date? {
        return transferDTO.dateStartValidity
    }
    
    var endDate: Date? {
        return transferDTO.dateEndValidity
    }
    
    var periodicalType: PeriodicalTransferType? {
        switch transferDTO.periodicalType {
        case .none, .none?, .weekly, .bimonthly, .annual:
            return nil
        case .monthly?:
            return .monthly
        case .trimestral?:
            return .trimestral
        case .semiannual?:
            return .semiannual
        }
    }
    
    var keyForPeriodicalType: String {
        switch transferDTO.periodicalType {
        case .none, .none?, .weekly, .bimonthly, .annual:
            return "summary_label_timely"
        case .monthly?:
            return "summary_label_monthly"
        case .trimestral?:
            return "summary_label_quarterly"
        case .semiannual?:
            return "summary_label_sixMonthly"
        }
    }
    
    var isPeriodic: Bool {
        return transferDTO.typeTransfer?.lowercased() == "p"
    }
    
    var periodicTrackerDescription: String {
        return isPeriodic ? "periodica" : "diferida"
    }
}

enum PeriodicalTransferType: String {
    case monthly
    case trimestral
    case semiannual
}
