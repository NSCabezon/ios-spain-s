import SANLegacyLibrary

public protocol CardSubscriptionGraphDataEntityRepresentable {
    var monthList: [CardSubscriptionMonthEntity]? { get }
    var yearList: [CardSubscriptionYearEntity]? { get }
}

public protocol CardSubscriptionMonthEntityRepresentable {
    var month: String? { get }
    var year: String? { get }
    var total: AmountEntity { get }
}

public protocol CardSubscriptionYearEntityRepresentable {
    var year: String? { get }
    var total: AmountEntity { get }
    var avg: AmountEntity { get }
}

public struct CardSubscriptionGraphDataEntity: CardSubscriptionGraphDataEntityRepresentable {
    private let dto: CardSubscriptionsGraphDataDTO
    
    public init(dto: CardSubscriptionsGraphDataDTO) {
        self.dto = dto
    }
    
    public var monthList: [CardSubscriptionMonthEntity]? {
        let monthList = self.dto.monthsList?.compactMap {
            CardSubscriptionMonthEntity(dto: $0)
        }
        return monthList
    }
    
    public var yearList: [CardSubscriptionYearEntity]? {
        let yearList = self.dto.yearList?.compactMap {
            CardSubscriptionYearEntity(dto: $0)
        }
        return yearList
    }
}

public struct CardSubscriptionMonthEntity: CardSubscriptionMonthEntityRepresentable {
    private let dto: CardSubscriptionMonthDTO
    
    public init(dto: CardSubscriptionMonthDTO) {
        self.dto = dto
    }
    
    public var month: String? {
        return self.dto.month
    }
    
    public var year: String? {
        return self.dto.year
    }
    
    public var total: AmountEntity {
        return AmountEntity(value: self.dto.total)
    }
}

public struct CardSubscriptionYearEntity: CardSubscriptionYearEntityRepresentable {
    private let dto: CardSubscriptionYearDTO
    
    public init(dto: CardSubscriptionYearDTO) {
        self.dto = dto
    }
    
    public var year: String? {
        return self.dto.year
    }
    
    public var total: AmountEntity {
        return AmountEntity(value: self.dto.total)
    }
    
    public var avg: AmountEntity {
        return AmountEntity(value: self.dto.avg)
    }
}
