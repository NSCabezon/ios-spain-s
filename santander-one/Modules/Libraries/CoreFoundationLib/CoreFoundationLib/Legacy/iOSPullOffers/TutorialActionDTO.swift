import CoreDomain

public struct TutorialAction: OfferActionRepresentable {
    public let topTitle: String?
    public let tutorialPages: [TutorialPage]
    public let type = "tutorial"
    
    public func getDeserialized() -> String {
        var output = ""
        if let topTitle = topTitle {
            output += "<top_title><![CDATA[\(topTitle)]]></top_title>"
        }
        if tutorialPages.count > 0 {
            output += "<list>"
            for page in tutorialPages {
                output += "<page>"
                if let title = page.title {
                    output += "<title><![CDATA[\(title)]]></title>"
                }
                if let description = page.description {
                    output += "<desc><![CDATA[\(description)]]></desc>"
                }
                if let banner = page.banner {
                    output += "<banners>"
                    output += "<banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">"
                    output += "<![CDATA[\(banner.url)]]>"
                    output += "</banner>"
                    output += "</banners>"
                }
                if let button = page.actionButton {
                    output += "<button>"
                    output += button.getDeserializad()
                    output += "</button>"
                }
                output += "</page>"
            }
            output += "</list>"
        }
        return output
    }
}
