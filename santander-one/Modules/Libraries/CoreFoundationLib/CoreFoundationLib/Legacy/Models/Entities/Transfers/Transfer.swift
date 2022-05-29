//
//  Transfer.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import SANLegacyLibrary

public enum TransferTime: Equatable {
    case now
    case day(date: Date)
    case periodic(startDate: Date, endDate: TransferTimeEndDate, periodicity: TransferPeriodicity, workingDayIssue: TransferWorkingDayIssue)
    
    struct Constants {
        static var scheduledTransferMinimumDate: Date {
            let components = DateComponents(day: 2)
            return Calendar.current.date(byAdding: components, to: Date()) ?? Date()
        }
        static var periodicTransferMinimumDate: Date {
            let components = DateComponents(day: 2)
            return Calendar.current.date(byAdding: components, to: Date()) ?? Date()
        }
    }
    
    public var trackerDescription: String {
        switch self {
        case .now: return "normal"
        case .day: return "diferida"
        case .periodic: return "periodica"
        }
    }
    
    public static var defaultDay: TransferTime {
        return .day(date: Constants.scheduledTransferMinimumDate)
    }
    
    public static var defaultPeriodic: TransferTime {
        return .periodic(startDate: Constants.periodicTransferMinimumDate, endDate: .never, periodicity: .monthly, workingDayIssue: .previousDay)
    }
    
    public static func periodic(from time: TransferTime, startDate: Date? = nil, endDate: TransferTimeEndDate? = nil, periodicity: TransferPeriodicity? = nil, workingDayIssue: TransferWorkingDayIssue? = nil) -> TransferTime {
        switch time {
        case .periodic(let currentDate, let currentEndDate, let currentPeriodicity, let currentWorkindDayIssue):
            return .periodic(startDate: startDate ?? currentDate, endDate: endDate ?? currentEndDate, periodicity: periodicity ?? currentPeriodicity, workingDayIssue: workingDayIssue ?? currentWorkindDayIssue)
        default:
            return defaultPeriodic
        }
    }
    
    public func isPeriodic() -> Bool {
        switch self {
        case .periodic:
            return true
        default:
            return false
        }
    }
    
    public static func == (lhs: TransferTime, rhs: TransferTime) -> Bool {
        switch (lhs, rhs) {
        case (.now, .now): return true
        case (.day, .day): return true
        case (.periodic, .periodic): return true
        default: return false
        }
    }
}

public enum TransferTimeEndDate {
    case never
    case date(Date)
}

public enum TransferPeriodicity: CustomStringConvertible, CaseIterable {
    
    case monthly
    case quarterly
    case biannual
    case weekly
    case bimonthly
    case annual
    
    public var dto: PeriodicalTypeTransferDTO {
        switch self {
        case .monthly: return .monthly
        case .quarterly: return .trimestral
        case .biannual: return .semiannual
        case .weekly: return .weekly
        case .bimonthly: return .bimonthly
        case .annual: return .annual
        }
    }
    
    public var description: String {
        switch self {
        case .monthly: return "periodicContribution_label_monthly"
        case .quarterly: return "periodicContribution_label_quarterly"
        case .biannual: return "periodicContribution_label_biannual"
        case .weekly: return "generic_label_weekly"
        case .bimonthly: return "generic_label_bimonthly"
        case .annual: return "periodicContribution_label_annual"
        }
    }
    
    public var periodicity: String {
        switch self {
        case .monthly: return "summary_label_monthly"
        case .quarterly: return "summary_label_quarterly"
        case .biannual: return "summary_label_sixMonthly"
        case .weekly: return "summary_label_weekly"
        case .bimonthly: return "summary_label_bimonthly"
        case .annual: return "summary_label_annual"
        }
    }
}

public enum TransferWorkingDayIssue: CustomStringConvertible, CaseIterable {
    
    case previousDay
    case laterDay
    
    public var dto: ScheduledDayDTO {
        switch self {
        case .previousDay: return .previous_day
        case .laterDay: return .next_day
        }
    }
    
    public var description: String {
        switch self {
        case .previousDay: return "sendMoney_label_previousWorkingDay"
        case .laterDay: return "sendMoney_label_laterWorkingDay"
        }
    }
}
