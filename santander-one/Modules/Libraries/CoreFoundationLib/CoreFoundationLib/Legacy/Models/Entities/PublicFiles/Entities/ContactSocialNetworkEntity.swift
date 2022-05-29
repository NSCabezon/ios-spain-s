import CoreDomain

public class ContactSocialNetworkEntity {
    
    public let dto: ContactSocialNetworkDTO?
    
    public var isActive: Bool? {
        return dto?.active == .yes
    }
    
    public var url: String? {
        return dto?.url
    }
    
    public var appURL: String? {
        return dto?.appUrl
    }
        
    public var mail: String? {
        return dto?.mail
    }
    public var phone: String? {
        return dto?.phone
    }
    public var hint: String? {
        return dto?.hint
    }
    
    public init(dto: ContactSocialNetworkDTO) {
        self.dto = dto
    }
}

extension ContactSocialNetworkEntity: ContactSocialNetworkRepresentable {}
