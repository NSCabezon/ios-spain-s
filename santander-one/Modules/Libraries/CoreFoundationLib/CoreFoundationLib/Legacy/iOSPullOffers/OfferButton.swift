import CoreDomain

public struct OfferButton {
    public let text: String
    public let background: [BannerDTO]?
    public let action: OfferActionRepresentable?
    
    public func getDeserializad() -> String {
        var output = "<text>\(text)</text>"
        
        if let background = background, background.count > 0 {
            output += "<background>"
            
            for banner in background {
                output += "<banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">" +
                    "<![CDATA[\(banner.url)]]>" +
                    "</banner>"
            }
            
            output += "</background>"
        }
        if let action = action {
             output += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
        }
       
        return output
    }
}
