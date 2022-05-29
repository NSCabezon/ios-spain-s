import CoreDomain

public struct BubbleBannerAction: OfferActionRepresentable {
    public let type = "bubble_banner"
    public let closeTime: Int
    public let banner: BannerDTO
    public let action: OfferActionRepresentable?
    
    public func getDeserialized() -> String {
        var output = ""
        output += "<close_time>\(closeTime)</close_time>"
        output += "<banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">"
        output += "<![CDATA[\(banner.url)]]>"
        output += "</banner>"
        if let action = action {
            output += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
        }
        return output
    }
}
