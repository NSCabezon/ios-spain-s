import Fuzi
import CoreDomain

class OfferButtonParser: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    func deserialize(_ parseable: OfferButton) -> String? {
        return ""
    }
    
    func serialize(_ responseString: String) -> OfferButton? {
        if let document = try? XMLDocument(string: responseString) {
            if let root = document.root {
                let text = root.children(tag: "text").first?.stringValue ?? ""
                var backgroundBanners = [BannerDTO]()
                if let background = root.firstChild(tag: "background") {
                    for banner in background.children(tag: "banner") {
                        var app = ""
                        var height = ""
                        var width = ""
                        for (key, value) in banner.attributes {
                            if key == "app" {
                                app = value
                            }
                            if key == "height" {
                                height = value
                            }
                            if key == "width" {
                                width = value
                            }
                        }
                        let url = banner.stringValue.replace("\n", "").trimed
                        let newBanner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
                        backgroundBanners.append(newBanner)
                    }
                }

                var action: OfferActionRepresentable?
                if let parsedAction = OfferActionParser().serialize(root.firstChild(staticTag: "action")?.description ?? "") {
                    action = parsedAction
                }
                
                return OfferButton(text: text, background: backgroundBanners, action: action)
            }
        }
        
        return nil
    }
    
}
