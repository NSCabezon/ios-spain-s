public struct CardSubscriptionsHistoricalListDTO: Codable {
    public var subscriptions: [CardSubscriptionHistoricalDTO]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        subscriptions = try? container.decode([CardSubscriptionHistoricalDTO].self)
    }
}
