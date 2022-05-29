import CoreDomain

public struct PullOfferLocation: Hashable {
    public let stringTag: String
    public let hasBanner: Bool
    public let pageForMetrics: String?
    
    public init(stringTag: String, hasBanner: Bool, pageForMetrics: String?) {
        self.stringTag = stringTag
        self.hasBanner = hasBanner
        self.pageForMetrics = pageForMetrics
    }
}

extension Dictionary where Key == PullOfferLocation, Value == OfferEntity {
    
    public func contains(location: String) -> Bool {
        return contains(where: { $0.key.stringTag == location })
    }
    
    public func location(key: String) -> (location: PullOfferLocation, offer: OfferEntity)? {
        guard let location = self.first(where: { $0.key.stringTag == key }) else { return nil }
        return (location.key, location.value)
    }
}

extension PullOfferLocation: Equatable {
    public static func == (lhs: PullOfferLocation, rhs: PullOfferLocation) -> Bool {
         return lhs.stringTag == rhs.stringTag
     }
}

extension PullOfferLocation: PullOfferLocationRepresentable {}
