import SANLegacyLibrary
import CoreFoundationLib

struct PersistedUser {
    
    var isPb: Bool? {
        return persistedUserDTO?.isPb
    }
    var name: String? {
        return persistedUserDTO?.name
    }
    var loginType: LoginIdentityDocumentType? {
        return persistedUserDTO?.loginType.doObject
    }
    var login: String? {
        return persistedUserDTO?.login
    }
    var channelFrame: String? {
        return persistedUserDTO?.channelFrame
    }

    var isMagicAllowed: Bool {
        if let persistedUserDTO = persistedUserDTO {
            return persistedUserDTO.environmentName.contains("CIBER")
        }
        return false
    }
    
    var persistedUserDTO: PersistedUserDTO?
    
    init?(dto: PersistedUserDTO?) {
        self.persistedUserDTO = dto
    }
    
    var isPB: Bool {
        return persistedUserDTO?.isPb ?? false
    }
    
    var bdpSegment: String? {
        return persistedUserDTO?.bdpCode
    }
    
    var commercialSegment: String? {
        return persistedUserDTO?.comCode
    }
    
    var isSmartUser: Bool {
        return persistedUserDTO?.isSmart ?? false
    }
}

private extension UserLoginType {
    var doObject: LoginIdentityDocumentType {
        switch self {
        case .N:
            return .nif
        case .C:
            return .nie
        case .S:
            return .cif
        case .I:
            return .passport
        case .U:
            return .user
        }
    }
}
