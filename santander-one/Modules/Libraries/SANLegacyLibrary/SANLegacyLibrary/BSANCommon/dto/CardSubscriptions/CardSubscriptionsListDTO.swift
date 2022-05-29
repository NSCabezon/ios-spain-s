public struct CardSubscriptionsListDTO: Codable {
    public var subscriptions: [CardSubscriptionDTO]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        subscriptions = try? container.decode([CardSubscriptionDTO].self)
    }
}
