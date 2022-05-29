public struct CarouselOffersInfoDTO: Codable {
    public let id: String
    public let expireOnClick: Bool
    public let priority: Int

    public init(id: String, expireOnClick: Bool = false, priority: Int = 0) {
        self.id = id
        self.expireOnClick = expireOnClick
        self.priority = priority
    }
}
