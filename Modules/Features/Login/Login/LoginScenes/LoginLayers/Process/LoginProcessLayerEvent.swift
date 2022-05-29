//
//  LoginProcessLayerEvent.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/19/20.
//

import Foundation
import CoreFoundationLib

public enum LoginProcessLayerEvent {
   public enum ErrorType {
        case any
        case wrongPassword
        case biometricDeeplink
        case biometricDocument
        case biometricSecurity
    }
    case willLogin
    case loginSuccess
    case fail(error: LocalizedStylableText, type: ErrorType)
    case userCanceled
    case failedBiometric
    case netWorkUnavailable
}
