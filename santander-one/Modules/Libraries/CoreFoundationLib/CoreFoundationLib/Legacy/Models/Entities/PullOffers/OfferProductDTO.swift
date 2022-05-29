import CoreDomain

public struct OfferProductDTO {
    public let identifier: String
    public let neverExpires: Bool
    public let transparentClosure: Bool?
    public let description: String?
    public let rulesIds: [String]
    public let iterations: Int
    public let banners: [BannerDTO]
    public let bannersContract: [BannerDTO]
    public let action: OfferActionRepresentable?
    public let startDateUTC: Date?
    public let endDateUTC: Date?
    
    public init(identifier: String,
                neverExpires: Bool,
                transparentClosure: Bool?,
                description: String?,
                rulesIds: [String],
                iterations: Int,
                banners: [BannerDTO],
                bannersContract: [BannerDTO],
                action: OfferActionRepresentable?,
                startDateUTC: Date?,
                endDateUTC: Date?) {
        self.identifier = identifier
        self.neverExpires = neverExpires
        self.transparentClosure = transparentClosure
        self.description = description
        self.rulesIds = rulesIds
        self.iterations = iterations
        self.banners = banners
        self.bannersContract = bannersContract
        self.action = action
        self.startDateUTC = startDateUTC
        self.endDateUTC = endDateUTC
    }
}
