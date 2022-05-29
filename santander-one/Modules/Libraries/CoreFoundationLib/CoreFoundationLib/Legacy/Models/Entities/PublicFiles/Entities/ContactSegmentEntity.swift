import CoreDomain

public class ContactSegmentEntity {
    public let superlinea: ContactPhoneEntity?
    public let cardBlock: ContactPhoneEntity?
    public let fraudFeedback: ContactPhoneEntity?
    public let twitterContact: ContactSocialNetworkEntity?
    public let facebookContact: ContactSocialNetworkEntity?
    public let whatsAppContact: ContactSocialNetworkEntity?
    public let mailContact: ContactSocialNetworkEntity?
    
    public init(dto: ContactSegmentDTO) {
        if let contact = dto.contactTwitter {
            self.twitterContact = ContactSocialNetworkEntity(dto: contact)
        } else {
            self.twitterContact = nil
        }
        if let contact = dto.contactFacebook {
            self.facebookContact = ContactSocialNetworkEntity(dto: contact)
        } else {
            self.facebookContact = nil
        }
        if let contact = dto.contactWhatsapp {
            self.whatsAppContact = ContactSocialNetworkEntity(dto: contact)
        } else {
            self.whatsAppContact = nil
        }
        if let contact = dto.contactMail {
            self.mailContact = ContactSocialNetworkEntity(dto: contact)
        } else {
            self.mailContact = nil
        }
        if let contact = dto.superlinea {
            self.superlinea = ContactPhoneEntity(dto: contact)
        } else {
            self.superlinea = nil
        }
        if let contact = dto.cardBlock {
            self.cardBlock = ContactPhoneEntity(dto: contact)
        } else {
            self.cardBlock = nil
        }
        if let contact = dto.fraudFeedback {
            self.fraudFeedback = ContactPhoneEntity(dto: contact)
        } else {
            self.fraudFeedback = nil
        }
    }
}

extension ContactSegmentEntity: ContactSegmentRepresentable {
    public var superlineaRepresentable: ContactPhoneRepresentable? {
        return superlinea
    }
    
    public var cardBlockRepresentable: ContactPhoneRepresentable? {
        return cardBlock
    }
    
    public var fraudFeedbackRepresentable: ContactPhoneRepresentable? {
        return fraudFeedback
    }
    
    public var twitterContactRepresentable: ContactSocialNetworkRepresentable? {
        return twitterContact
    }
    
    public var facebookContactRepresentable: ContactSocialNetworkRepresentable? {
        return facebookContact
    }
    
    public var whatsAppContactRepresentable: ContactSocialNetworkRepresentable? {
        return whatsAppContact
    }
    
    public var mailContactRepresentable: ContactSocialNetworkRepresentable? {
        return mailContact
    }
}
