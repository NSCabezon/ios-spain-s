import CoreDomain

public struct ImageListAction: OfferActionRepresentable {
    public let topTitle: String?
    public let list: [ListPageDTO]
    public let type = "image_list_fullscreen"
    
    public init(topTitle: String?, list: [ListPageDTO]) {
        self.topTitle = topTitle
        self.list = list
    }
    
    public func getDeserialized() -> String {
        var output = ""
        if let topTitle = topTitle {
            output = "<top_title>\(topTitle)</top_title>"
        }
        output += "<list>"
        for page in list {
            output += "<page><image_fullscreen><![CDATA[\(page.imageFullscreen)]]></image_fullscreen>"
            
            if let action = page.action {
                output += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
            }
            
            output += "</page>"
        }
        
        output += "</list>"
        
        return output
    }
}
