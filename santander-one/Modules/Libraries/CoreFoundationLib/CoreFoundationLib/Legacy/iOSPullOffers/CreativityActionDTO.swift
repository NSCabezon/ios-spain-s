import CoreDomain

public struct CreativityAction: OfferActionRepresentable {
    public let topTitle: String
    public let title: String
    public let buttonUp: OfferButton?
    public let buttonLeft: OfferButton?
    public let buttonRight: OfferButton?
    public let carousel: [BannerDTO]
    public let type = "creativity"
    
    public init(topTitle: String, title: String, buttonUp: OfferButton?, buttonLeft: OfferButton?, buttonRight: OfferButton?, carousel: [BannerDTO]) {
        self.topTitle = topTitle
        self.title = title
        self.buttonUp = buttonUp
        self.buttonLeft = buttonLeft
        self.buttonRight = buttonRight
        self.carousel = carousel
    }
    
    public func getDeserialized() -> String {
        var output = "<top_title>\(topTitle)</top_title>" +
            "<title>\(title)</title>"
        
        if let buttonUp = buttonUp {
            output += "<button_up>\(buttonUp.getDeserializad())</button_up>"
        }
        
        if let buttonLeft = buttonLeft {
            output += "<button_left>\(buttonLeft.getDeserializad())</button_left>"
        }
        
        if let buttonRight = buttonRight {
            output += "<button_right>\(buttonRight.getDeserializad())</button_right>"
        }
        
        output += "<carousel>"
        
        let iosBanners = carousel.filter({$0.app.lowercased().contains("ios") && !$0.app.lowercased().contains("android")})
        let androidBanners = carousel.filter({!$0.app.lowercased().contains("ios") && $0.app.lowercased().contains("android")})
        let commonBanners = carousel.filter({$0.app.lowercased().contains("ios") && $0.app.lowercased().contains("android")})

        if iosBanners.count > 0 {
            output += "<creativity_images app=\"ios\">"

            for banner in iosBanners {
                output += "<creativity_image height=\"\(banner.height)\" width=\"\(banner.width)\">" +
                    "<![CDATA[\(banner.url)]]>" +
                "</creativity_image>"
            }
            
            output += "</creativity_images>"
        }
        
        if androidBanners.count > 0 {
            output += "<creativity_images app=\"android\">"
            
            for banner in androidBanners {
                output += "<creativity_image height=\"\(banner.height)\" width=\"\(banner.width)\">" +
                    "<![CDATA[\(banner.url)]]>" +
                "</creativity_image>"
            }
            
            output += "</creativity_images>"
        }
        
        if commonBanners.count > 0 {
            output += "<creativity_images app=\"\(commonBanners.first!.app)\">"
            
            for banner in commonBanners {
                output += "<creativity_image height=\"\(banner.height)\" width=\"\(banner.width)\">" +
                    "<![CDATA[\(banner.url)]]>" +
                "</creativity_image>"
            }
            
            output += "</creativity_images>"
        }
        
        output += "</carousel>"
        
        return output
    }
}
