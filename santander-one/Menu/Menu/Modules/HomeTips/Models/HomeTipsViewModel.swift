import CoreFoundationLib

struct HomeTipsCellViewModel {
    let title: String
    let content: [HomeTipsViewModel]
    var position: CGPoint?
}

struct HomeTipsViewModel {
    let title: LocalizedStylableText
    let description: LocalizedStylableText
    let icon: String?
    let tag: LocalizedStylableText?
    let offerId: String?
    let keyWords: [String]?
    let baseUrl: String?
    
    var tipImageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let icon = self.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
}
