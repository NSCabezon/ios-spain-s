import CoreDomain

public struct DetailAction: OfferActionRepresentable {
    public let topTitle: String?
    public let description: String?
    public let detailBanner: BannerDTO?
    public let button1: OfferButton?
    public let button2: OfferButton?
    public let type = "detail"

    public func getDeserialized() -> String {
        var output = ""
        if let topTitle = topTitle {
            output += "<top_title><![CDATA[\(topTitle)]]></top_title>"
        }
        if let description = description {
            output += "<description><![CDATA[\(description)]]></description>"
        }
        if let banner = detailBanner {
            output += "<detail_banners>"
            output += "<detail_banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">"
            output += "<![CDATA[\(banner.url)]]>"
            output += "</detail_banner>"
            output += "</detail_banners>"
        }
        if let button1 = button1 {
            output += "<button_1>\(button1.getDeserializad())</button_1>"
        }
        if let button2 = button2 {
            output += "<button_2>\(button2.getDeserializad())</button_2>"
        }
        return output
    }
}
