public protocol ContactSegmentRepresentable {
    var superlineaRepresentable: ContactPhoneRepresentable? { get }
    var cardBlockRepresentable: ContactPhoneRepresentable? { get }
    var fraudFeedbackRepresentable: ContactPhoneRepresentable? { get }
    var twitterContactRepresentable: ContactSocialNetworkRepresentable? { get }
    var facebookContactRepresentable: ContactSocialNetworkRepresentable? { get }
    var whatsAppContactRepresentable: ContactSocialNetworkRepresentable? { get }
    var mailContactRepresentable: ContactSocialNetworkRepresentable? { get }
}

public protocol ContactPhoneRepresentable {
    var title: String? { get }
    var desc: String? { get }
    var numbers: [String]? { get }
}

public protocol ContactSocialNetworkRepresentable {
    var isActive: Bool? { get }
    var url: String? { get }
    var appURL: String? { get }
    var mail: String? { get }
    var phone: String? { get }
    var hint: String? { get }
}
