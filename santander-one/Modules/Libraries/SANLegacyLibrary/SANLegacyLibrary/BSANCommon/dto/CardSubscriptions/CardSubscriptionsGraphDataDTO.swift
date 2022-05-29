public struct CardSubscriptionsGraphDataDTO: Codable {
    public var monthsList: [CardSubscriptionMonthDTO]?
    public var yearList: [CardSubscriptionYearDTO]?
    
    enum CodingKeys: String, CodingKey {
        case monthsList = "MESES"
        case yearList = "ANYOS"
    }
}

public struct CardSubscriptionMonthDTO: Codable {
    public let month: String?
    public let year: String?
    public let total: Decimal

    enum CodingKeys: String, CodingKey {
        case month = "MES"
        case year = "ANYO"
        case total = "TOTAL"
    }
}

public struct CardSubscriptionYearDTO: Codable {
    public let year: String?
    public let total: Decimal
    public let avg: Decimal

    enum CodingKeys: String, CodingKey {
        case year = "ANYO"
        case total = "TOTAL"
        case avg = "MEDIA"
    }
}

