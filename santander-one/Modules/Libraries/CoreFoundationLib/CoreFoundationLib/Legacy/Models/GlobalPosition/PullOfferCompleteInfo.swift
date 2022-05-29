public struct PullOfferCompleteInfo {
    public let location: PullOfferLocation
    public let entity: OfferEntity
    
    public init(location: PullOfferLocation, entity: OfferEntity) {
        self.location = location
        self.entity = entity
    }
}
