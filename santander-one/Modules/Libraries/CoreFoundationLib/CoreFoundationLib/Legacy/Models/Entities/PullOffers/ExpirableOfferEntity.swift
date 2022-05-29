public final class ExpirableOfferEntity: OfferEntity {
    public let expiresOnClick: Bool
    
    public required init(_ dto: OfferDTO) {
        expiresOnClick = false
        super.init(dto)
    }
    
    public override init(_ dto: OfferDTO, location: PullOfferLocation) {
        expiresOnClick = false
        super.init(dto, location: location)
    }
    
    public init(_ dto: OfferDTO, location: PullOfferLocation, expiresOnClick: Bool) {
        self.expiresOnClick = expiresOnClick
        super.init(dto, location: location)
    }
}
