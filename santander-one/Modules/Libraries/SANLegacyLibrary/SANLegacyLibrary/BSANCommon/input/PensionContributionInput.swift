import Foundation

public struct PensionContributionInput {
    public var startDate: String
    public var periodicyType: PeriodicityType
    public var amountDTO: AmountDTO
    public var percentage: String
    public var revaluationType: RevaluationType
    
    public init(startDate: Date, periodicyType: PeriodicityType, amountDTO: AmountDTO, percentage: String, revaluationType: RevaluationType) {
        self.startDate = DateFormats.toString(date: startDate, output: DateFormats.TimeFormat.YYYYMMDD)
        self.periodicyType = periodicyType
        self.amountDTO = amountDTO
        self.percentage = percentage
        self.revaluationType = revaluationType
    }
    
    public mutating func setStartDate(startDate: String) -> PensionContributionInput {
        self.startDate = startDate
        return self
    }
    
    public mutating func setPeriodicityType(periodicyType: PeriodicityType) -> PensionContributionInput {
        self.periodicyType = periodicyType
        return self
    }
    
    public mutating func setAmountDTO(amountDTO: AmountDTO) -> PensionContributionInput {
        self.amountDTO = amountDTO
        return self
    }
    
    public mutating func setPercentage(percentage: String) -> PensionContributionInput {
        self.percentage = percentage
        return self
    }
    
    public mutating func setRevaluationType(revaluationType: RevaluationType) -> PensionContributionInput {
        self.revaluationType = revaluationType
        return self
    }
}

public struct PeriodicityType {
    
    public static var monthly: PeriodicityType {
        return PeriodicityType(frequencyQuota: FrequencyQuota.one, unitTime: UnitTime.month)
    }
    
    public static var quarterly: PeriodicityType {
        return PeriodicityType(frequencyQuota: FrequencyQuota.three, unitTime: UnitTime.month)
    }
    
    public static var biannual: PeriodicityType {
        return PeriodicityType(frequencyQuota: FrequencyQuota.six, unitTime: UnitTime.month)
    }
    
    public static var annual: PeriodicityType {
        return PeriodicityType(frequencyQuota: FrequencyQuota.one, unitTime: UnitTime.year)
    }

    private var frequencyQuota: FrequencyQuota
    private var unitTime: UnitTime
    
    public init(frequencyQuota: FrequencyQuota, unitTime: UnitTime) {
        self.frequencyQuota = frequencyQuota
        self.unitTime = unitTime
    }
    
    public func getFrequencyQuota() -> String {
        return self.frequencyQuota.rawValue
    }
    
    public func getUnitTime() -> String {
        return self.unitTime.rawValue
    }
}

public struct RevaluationType {
    
    public static var without_revaluation: RevaluationType {
        return RevaluationType(indexRevaluesPension: IndexRevalue.notRevalorized, typeRevaluesPension: RevalueType.notRevalorized)
    }
    
    public static var according_ipc: RevaluationType {
        return RevaluationType(indexRevaluesPension: IndexRevalue.revalorized, typeRevaluesPension: RevalueType.ipc)
    }
    
    public static var according_percentage: RevaluationType {
        return RevaluationType(indexRevaluesPension: IndexRevalue.revalorized, typeRevaluesPension: RevalueType.percentage)
    }
    
    private var indexRevaluesPension: IndexRevalue
    private var typeRevaluesPension: RevalueType
    
    public init(indexRevaluesPension: IndexRevalue, typeRevaluesPension: RevalueType) {
        self.indexRevaluesPension = indexRevaluesPension
        self.typeRevaluesPension = typeRevaluesPension
    }
    
    public func getIndexRevaluesPension() -> String {
        return self.indexRevaluesPension.rawValue
    }
    
    public func getTypeRevaluesPension() -> String {
        return self.typeRevaluesPension.rawValue
    }
}

public enum RevalueType: String {
    case notRevalorized = " "
    case ipc = "P"
    case percentage = "F"
}

public enum IndexRevalue: String {
    case notRevalorized = "N"
    case revalorized = "S"
}

public enum FrequencyQuota: String {
    case one = "01"
    case three = "03"
    case six = "06"
}

public enum UnitTime: String {
    case month = "2"
    case year = "3"
}
