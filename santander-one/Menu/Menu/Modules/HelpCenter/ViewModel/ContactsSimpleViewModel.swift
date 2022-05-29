import CoreFoundationLib

enum ContactsSimpleViewModelAction {
    case chat
    case whatsapp
    case officeDate
}

struct ContactsSimpleViewModel {
    let title: LocalizedStylableText?
    let subtitle: LocalizedStylableText?
    let icon: String
    let action: ContactsSimpleViewModelAction
    let offer: OfferEntity?
    
    init(title: LocalizedStylableText,
         subtitle: LocalizedStylableText? = nil,
         icon: String,
         action: ContactsSimpleViewModelAction,
         offer: OfferEntity? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.offer = offer
    }
}
