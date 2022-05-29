//
//  LoginProcessLayerError.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/19/20.
//

import Foundation
import CoreFoundationLib

final class LoginProcessLayerError<Error: LoginUseCaseErrorOutput> {
    private let useCaseError: UseCaseError<Error>
    private let authLogin: AuthLogin
    private var errorEvent: LoginProcessLayerEvent = .userCanceled
    private let dependenciesResolver: DependenciesResolver
    
    private var getLoginErrorLinksUseCase: GetLoginErrorLinksUseCase {
        self.dependenciesResolver.resolve(for: GetLoginErrorLinksUseCase.self)
    }
    
    init(dependenciesResolver: DependenciesResolver,
         useCaseError: UseCaseError<Error>, authLogin: AuthLogin) {
        self.dependenciesResolver = dependenciesResolver
        self.useCaseError = useCaseError
        self.authLogin = authLogin
    }
    
    func failEvent() -> LoginProcessLayerEvent {
        self.proccessError()
        return self.errorEvent
    }
}

private extension LoginProcessLayerError {
    func proccessError() {
        switch self.useCaseError {
        case .error(let error):
            self.setLoginFail(with: error)
        case .generic, .unauthorized:
            self.setLoginFailWithGenericError()
        case .networkUnavailable:
            self.errorEvent = .netWorkUnavailable
        default:
            self.errorEvent = .fail(error: localized("generic_error_app"), type: .any)
        }
    }
    
    func setLoginFail(with error: LoginUseCaseErrorOutput?) {
        switch error?.getLoginErrorType() {
        case .userCanceled:
            self.errorEvent = .userCanceled
        case .emptyNumDoc:
            self.errorEvent = .fail(error: localized("login_popup_idRequired"), type: .any)
        case .emptyPass:
            self.errorEvent = .fail(error: localized("login_popup_passwordRequired"), type: .any)
        case .passTooShort:
            self.errorEvent = .fail(error: localized("login_popup_passwordError"), type: .any)
        case .noNumDoc:
            self.errorEvent = .fail(error: localized("login_error_typeDocument"), type: .any)
        case .docNoValid:
            self.errorEvent = .fail(error: localized("login_popup_idError"), type: .any)
        case .wrongPassword:
            self.setLogingFailWithWrongCredential()
        case .passBlocked:
            self.errorEvent = .fail(error: localized("login_error_blockedAccess"), type: .any)
        case .biometric:
            self.errorEvent = .failedBiometric
        case .biometricDeeplink:
            self.errorEvent = .fail(error: localized("operative_error_FACSEG_50201036"), type: .biometricDeeplink)
        case .biometricDocument:
            self.errorEvent = .fail(error: localized("operative_error_FACESEG_40201004"), type: .biometricDocument)
        case .biometricSecurity:
            self.errorEvent = .fail(error: localized("fingerprint_text_security"), type: .biometricSecurity)
        case .versionBlocked(let error):
            self.errorEvent = .fail(error: localized(error), type: .any)
        case .none, .emptyField, .persistedUserFailed, .footprintError, .serviceFault, .temporaryLocked, .unauthorized:
            self.setFailLoginWith(errorDescription: error?.getErrorDesc())
        }
    }
    
    func setFailLoginWith(errorDescription: String?) {
        if let error = errorDescription, !error.isEmpty {
            self.errorEvent = .fail(error: localized(error), type: .any)
        } else {
            switch authLogin {
            case .biometric:
                self.errorEvent = .fail(error: localized("login_error_touchId"), type: .any)
            case .magic:
                self.errorEvent = .fail(error: localized("login_error_generic"), type: .any)
            }
        }
    }
    
    func setLogingFailWithWrongCredential() {
        MainThreadUseCaseWrapper(
            with: self.getLoginErrorLinksUseCase,
            onSuccess: { result in
                let getNewPassword = result.obtainKeysUrl ?? ""
                let forgotPassword = result.recoverKeysUrl ?? ""
                let stringPlaceholders = [StringPlaceholder(.value, forgotPassword), StringPlaceholder(.value, getNewPassword)]
                self.errorEvent = .fail(error: localized("login_alert_wrongCredentials", stringPlaceholders), type: .wrongPassword)
            }
        )
    }
    
    func setLoginFailWithGenericError() {
        switch authLogin {
        case .biometric:
            self.errorEvent = .fail(error: localized("login_error_touchId"), type: .any)
        case .magic:
            self.errorEvent = .fail(error: localized("login_error_generic"), type: .any)
        }
    }
}
