public struct TutorialPage {
    
    public let title: String?
    public let description: String?
    public let banner: BannerDTO?
    public let actionButton: OfferButton?
    
    public init(title: String?, description: String?, banner: BannerDTO?, actionButton: OfferButton?) {
        self.title = title
        self.description = description
        self.banner = banner
        self.actionButton = actionButton
    }
}
