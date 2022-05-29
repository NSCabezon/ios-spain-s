//
//  File.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/17/20.
//

import Foundation
import CoreFoundationLib

public enum LoginState {
    case none
    case start
    case login
    case globalPosition
}

public enum AuthLogin {
    case magic(String)
    case biometric(biometricToken: String, footprint: String, channelFrame: String, isPb: Bool)
}

public enum LoginType {
    case notPersisted(identification: String, magic: String?, type: LoginIdentityDocumentType, remember: Bool)
    case persisted(AuthLogin)
}
