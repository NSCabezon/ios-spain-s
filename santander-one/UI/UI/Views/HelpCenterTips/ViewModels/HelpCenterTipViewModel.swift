import CoreFoundationLib

public struct HelpCenterTipViewModel {
    public let title: LocalizedStylableText
    public let description: LocalizedStylableText
    public let descriptionBackground: UIColor
    public let baseUrl: String?
    public let entity: PullOfferTipEntity
    public let highlightedDescriptionKey: String?
    
    public var tipImageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let icon = self.entity.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
    
    public var isHighlighted: Bool {
        return highlightedDescriptionKey != nil
    }
    
    public var tag: String? {
        entity.tag
    }
    
    public init(_ entity: PullOfferTipEntity,
                baseUrl: String?,
                highlightedDescriptionKey: String? = nil,
                descriptionBackground: UIColor = UIColor.white.withAlphaComponent(0.95)) {
        self.title = localized(entity.title ?? "")
        self.description = localized(entity.description ?? "")
        self.baseUrl = baseUrl
        self.entity = entity
        self.highlightedDescriptionKey = highlightedDescriptionKey
        self.descriptionBackground = descriptionBackground
    }
    
    func highlight(_ baseString: NSAttributedString?) -> NSAttributedString {
        guard let baseString = baseString, let highlightedDescriptionKey = highlightedDescriptionKey else { return NSAttributedString() }
        let ranges = baseString.string.ranges(of: highlightedDescriptionKey.trim()).map { NSRange($0, in: highlightedDescriptionKey) }
        return ranges.reduce(NSMutableAttributedString(attributedString: baseString)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
}
