public struct SanflixContractInfo {
    public let isEnabled: Bool
    public let offer: OfferEntity?
    public let location: PullOfferLocation?
    
    public init(isEnabled: Bool, offer: OfferEntity?, location: PullOfferLocation?) {
        self.isEnabled = isEnabled
        self.offer = offer
        self.location = location
    }
}
