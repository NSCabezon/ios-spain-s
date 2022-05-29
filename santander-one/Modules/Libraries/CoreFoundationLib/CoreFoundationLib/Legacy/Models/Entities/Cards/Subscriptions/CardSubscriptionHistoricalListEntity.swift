import SANLegacyLibrary

public protocol CardSubscriptionHistoricalListEntityRepresentable {
    var subscriptions: [CardSubscriptionHistoricalEntity]? { get }
}

public protocol CardSubscriptionHistoricalEntityRepresentable {
    var providerName: String { get }
    var date: Date? { get }
    var operationSign: String? { get }
    var amount: AmountDTO? { get }
    var isFractionable: Bool { get }
    var creditMovementNum: String? { get }
    var creditExtractNum: String? { get }
}

public struct CardSubscriptionHistoricalListEntity: CardSubscriptionHistoricalListEntityRepresentable {
    private let dto: CardSubscriptionsHistoricalListDTO
    
    public init(dto: CardSubscriptionsHistoricalListDTO) {
        self.dto = dto
    }
    
    public var subscriptions: [CardSubscriptionHistoricalEntity]? {
        let subscriptionsList = self.dto.subscriptions?.compactMap {
            CardSubscriptionHistoricalEntity(dto: $0)
        }
        return subscriptionsList
    }
}

public struct CardSubscriptionHistoricalEntity: CardSubscriptionHistoricalEntityRepresentable {
    private let dto: CardSubscriptionHistoricalDTO
    
    public init(dto: CardSubscriptionHistoricalDTO) {
        self.dto = dto
    }
    
    public var providerName: String {
        return dto.providerName?.trim() ?? ""
    }
    
    public var date: Date? {
        guard let optionalStringDate = dto.date else { return nil }
        return DateFormats.toDate(string: optionalStringDate, output: .YYYYMMDD)
    }
    
    public var operationSign: String? {
        dto.operationSign
    }
    
    public var amount: AmountDTO? {
        dto.amount
    }
    
    public var isFractionable: Bool {
        dto.isFractionable
    }
    
    public var creditMovementNum: String? {
        dto.creditMovementNum
    }
    
    public var creditExtractNum: String? {
        dto.creditExtractNum
    }
}
