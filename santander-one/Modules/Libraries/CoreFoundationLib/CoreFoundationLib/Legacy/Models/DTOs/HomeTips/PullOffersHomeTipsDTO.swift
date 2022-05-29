import CoreDomain

public struct PullOffersHomeTipsDTO: Codable {
    public let title: String
    public let content: [PullOffersHomeTipsContentDTO]?
    
    public init(title: String, content: [PullOffersHomeTipsContentDTO]?) {
        self.title = title
        self.content = content
    }
}

extension PullOffersHomeTipsDTO: PullOffersHomeTipsRepresentable {
    public var contentRepresentable: [PullOffersHomeTipsContentRepresentable]? {
        return content
    }
}

public struct PullOffersHomeTipsContentDTO: Codable {
    public let title: String?
    public let desc: String?
    public let icon: String?
    public let tag: String?
    public let offerId: String?
    public let keyWords: [String]?
    
    public init(title: String?, desc: String?, icon: String?, tag: String?, offerId: String?, keyWords: [String]?) {
        self.title = title
        self.desc = desc
        self.icon = icon
        self.tag = tag
        self.offerId = offerId
        self.keyWords = keyWords
    }
}

extension PullOffersHomeTipsContentDTO: PullOffersHomeTipsContentRepresentable { }
