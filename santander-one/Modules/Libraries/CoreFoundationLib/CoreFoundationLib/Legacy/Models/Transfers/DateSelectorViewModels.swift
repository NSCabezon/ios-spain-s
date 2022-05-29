public enum SendMoneyDateTypeViewModel {
    case now
    case day
    case periodic
}

public enum SendMoneyDateTypeFilledViewModel {
    case now
    case day(date: Date)
    case periodic(start: Date, end: PeriodicEndDateTypeFilledViewModel, periodicity: SendMoneyPeriodicityTypeViewModel, emission: SendMoneyEmissionTypeViewModel)
}

public enum PeriodicEndDateTypeFilledViewModel {
    case never
    case date(Date)
}

public enum SendMoneyPeriodicityTypeViewModel: Int, CaseIterable {
    case month = 0
    case quarterly = 1
    case semiannual = 2
    case weekly = 3
    case bimonthly = 4
    case annual = 5
    
    public var text: String {
        let key: String
        switch self {
        case .month:
            key = "generic_label_monthly"
        case .quarterly:
            key = "generic_label_quarterly"
        case .semiannual:
            key = "generic_label_biannual"
        case .weekly:
            key = "generic_label_weekly"
        case .bimonthly:
            key = "generic_label_bimonthly"
        case .annual:
            key = "generic_label_annual"
        }
        return key
    }
}

public enum SendMoneyEmissionTypeViewModel: Int, CaseIterable {
    case previous = 0
    case next = 1
    
    public var text: String {
        let key: String
        switch self {
        case .previous:
            key = "sendMoney_label_previousWorkingDay"
        case .next:
            key = "sendMoney_label_laterWorkingDay"
        }
        return key
    }
}
