//
//  PersistedUserEntity.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation
import SANLegacyLibrary

public struct PersistedUserEntity {
    
    public var isPb: Bool? {
        return persistedUserDTO?.isPb
    }
    public var name: String? {
        return persistedUserDTO?.name
    }
    public var loginType: LoginIdentityDocumentType? {
        return persistedUserDTO?.loginType.doObject
    }
    public var login: String? {
        return persistedUserDTO?.login
    }
    public var channelFrame: String? {
        return persistedUserDTO?.channelFrame
    }

    public var isMagicAllowed: Bool {
        if let persistedUserDTO = persistedUserDTO {
            return persistedUserDTO.environmentName.contains("CIBER")
        }
        return false
    }
    
    public var persistedUserDTO: PersistedUserDTO?
    
    public init?(dto: PersistedUserDTO?) {
        self.persistedUserDTO = dto
    }
    
    public var isPB: Bool {
        return persistedUserDTO?.isPb ?? false
    }
    
    public var bdpSegment: String? {
        return persistedUserDTO?.bdpCode
    }
    
    public var commercialSegment: String? {
        return persistedUserDTO?.comCode
    }
    
    public var isSmartUser: Bool {
        return persistedUserDTO?.isSmart ?? false
    }
    
    public var biometryData: Data? {
        return persistedUserDTO?.biometryData
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
