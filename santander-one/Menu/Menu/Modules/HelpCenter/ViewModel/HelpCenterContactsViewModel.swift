import CoreFoundationLib

struct HelpCenterContactsViewModel {
    let superline: HelpCenterContactsSupelineViewModel?
    let whatsApp: HelpCenterContactsWhatsAppViewModel?
    let permanetAttention: PermanentAttentionViewModel?
    let isChatEnabled: Bool
    let isUserSmart: Bool
    let isProductOneVIP: Bool
    
    var isEmpty: Bool {
        return superline == nil && whatsApp == nil && permanetAttention == nil && !isChatEnabled && !isProductOneVIP
    }
}

public struct HelpCenterContactsSupelineViewModel {
    public let title: String?
    public let description: String?
    public let numbers: [String]
    
    public init(title: String?, description: String?, numbers: [String]) {
        self.title = title
        self.description = description
        self.numbers = numbers
    }
}

struct HelpCenterContactsWhatsAppViewModel {
    let hint: String?
}

struct PermanentAttentionViewModel {
    var offer: OfferEntity?
    var action: ((OfferEntity?) -> Void)?
    
    var imageUrl: String? {
        return offer?.banner?.url
    }
}
