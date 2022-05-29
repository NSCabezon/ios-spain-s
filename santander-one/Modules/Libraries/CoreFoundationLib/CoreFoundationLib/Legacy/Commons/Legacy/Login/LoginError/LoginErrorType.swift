//
//  LoginErrorType.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

public enum LoginErrorType {
    // Local Validations
    case emptyField
    case persistedUserFailed
    case footprintError

    case emptyNumDoc
    case emptyPass
    case passTooShort

    case noNumDoc
    case docNoValid
    case versionBlocked(error: String)
    // Services SpecificErrors
    case serviceFault
    // Shake Canceled
    case userCanceled

    // Service error management
    case wrongPassword
    case passBlocked
    case unauthorized
    case biometric
    case temporaryLocked
    case biometricDeeplink
    case biometricDocument
    case biometricSecurity
}
