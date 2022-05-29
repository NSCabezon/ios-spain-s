public struct CardSubscriptionDTO: Codable {
    public let pan: String?
    public let providerName: String?
    public let lastUseDate: String?
    public let value: String?
    public let currency: String?
    public let lastStateChangeDate: String?
    public let cardProductCode: String?
    public let cardSubproductCode: String?
    public let cardEconomicCondition: String?
    public let cardPrintedCode: String?
    public let cardBrandCode: String?
    public let cardType: String?
    public let status: String?
    public let instaId: String?
    public let fractionableIndicator: String?
    public let creditExtractNum: String?
    public let creditMovementNum: String?
    public let debitMovementNum: String?
    public let operationSign: String?
    
    public var lastUseAmount: AmountDTO? {
        guard let value = value,
              let doubleValue = Double(value),
              let currency = currency else { return nil }
        return AmountDTO(value: Decimal(doubleValue),
                         currency: CurrencyDTO.create(currency))
    }
    
    public var subscriptionStatus: SubscriptionStatusCode? {
        guard let status = status else { return nil }
        return SubscriptionStatusCode(rawValue: status.trim())
    }
    
    public var isFractionable: Bool {
        return fractionableIndicator?.trim().uppercased() == "S"
    }

    enum CodingKeys: String, CodingKey {
        case pan = "pan"
        case providerName = "nomprod1"
        case lastUseDate = "feultuso"
        case value = "impopera"
        case currency = "clamon1"
        case lastStateChangeDate = "fecultmo"
        case cardProductCode = "cdgprodu"
        case cardSubproductCode = "cdgsubp"
        case cardEconomicCondition = "conprod"
        case cardPrintedCode = "condest"
        case cardBrandCode = "cdgmar"
        case cardType = "indtip"
        case status = "estado"
        case instaId = "insta_id"
        case fractionableIndicator = "incompcu"
        case creditExtractNum = "nuextcta"
        case creditMovementNum = "numvtoex"
        case debitMovementNum = "numovdeb"
        case operationSign = "signo"
    }
}

public enum SubscriptionStatusCode: String, Codable {
    case ACT
    case SUSP
}
