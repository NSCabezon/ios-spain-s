import CoreDomain

public struct PullOffersConfigTipDTO: Codable {
    public let title: String?
    public let desc: String?
    public let icon: String?
    public let offerId: String?
    public let tag: String?
    public let keyWords: [String]?
    
    public init(_ pullOffersConfigTipDTO: PullOffersHomeTipsContentDTO) {
        self.title = pullOffersConfigTipDTO.title
        self.desc = pullOffersConfigTipDTO.desc
        self.icon = pullOffersConfigTipDTO.icon
        self.tag = pullOffersConfigTipDTO.tag
        self.offerId = pullOffersConfigTipDTO.offerId
        self.keyWords = pullOffersConfigTipDTO.keyWords
    }
}

extension PullOffersConfigTipDTO: PullOfferTipRepresentable {
    public var description: String? {
        return desc
    }
    
    public var offerRepresentable: OfferRepresentable? {
        nil
    }
}
