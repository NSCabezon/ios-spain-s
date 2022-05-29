//
//  LoginServiceErrorAdapter.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/17/20.
//

import Foundation
import CoreFoundationLib

final class LoginServiceErrorAdapter: LoginUseCaseErrorOutput {
    private let errorDesc: String?
    private let code: String?
    private let notFoundTye: LoginErrorType?
    
    init(errorDesc: String?, code: String?, notFoundTye: LoginErrorType? = nil) {
        self.errorDesc = errorDesc
        self.code = code
        self.notFoundTye = notFoundTye
        super.init(errorDesc)
        self.setLoginErrorType()
    }
}

private extension LoginServiceErrorAdapter {
    func setLoginErrorType() {
        if let errorType: LoginErrorType = self.processErrorCodes(code) {
            loginErrorType = errorType
        } else if let errorType: LoginErrorType = self.processErrorDescription(errorDesc) {
            loginErrorType = errorType
        } else if let errorType: LoginErrorType = notFoundTye {
            loginErrorType = errorType
        }
    }
    
    func processErrorCodes(_ errorCode: String?) -> LoginErrorType? {
        switch errorCode {
        case "FACSEG_50201036":
            return .biometricDeeplink
        case "FACESEG_40201004":
            return .biometricDocument
        case "FACESEG_40201003":
            return .biometricSecurity
        default:
            return nil
        }
    }

     func processErrorDescription(_ errorDesc: String?) -> LoginErrorType? {
        guard let errorMessage = errorDesc?.lowercased() else {
            return nil
        }
        if errorMessage.contains("no encontrado")
            || errorMessage.contains("incorrecta")
            || errorMessage.contains("no es correcta") {
            return .wrongPassword
        } else if errorMessage.contains("el usuario estã¡ bloqueado")
            || errorMessage.contains("contraseña revocada")
            || errorMessage.contains("el usuario está bloqueado") {
            return .passBlocked
        } else {
            return nil
        }
    }
}
