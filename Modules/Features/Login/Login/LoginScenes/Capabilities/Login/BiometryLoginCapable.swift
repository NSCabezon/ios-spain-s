//
//  BiometryLoginCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/9/20.
//

import Foundation
import CoreFoundationLib
import LoginCommon
import CorePushNotificationsService
import ESCommons

protocol BiometryLoginView: LoginViewCapable {
    func setAvailableBiometryType(_ biometryType: BiometryTypeEntity)
    func displayLoginWithTouchIDView()
    func displayLoginWithNumberPadView()
    func displayLoginWithFaceIDView()
    func disableTouchIDView()
    func enableTouchIDView()
    func enableSideMenu()
    func disableSideMenu()
    func isViewActive(completion: @escaping (Bool) -> Void)
    func showBiometryDialog(titleKey: String, descriptionKey: String, acceptKey: String,
                            onAccept: @escaping () -> Void, onClose: @escaping () -> Void)
}

protocol BiometryLoginCapable: class {
    var dependenciesResolver: DependenciesResolver { get }
    var coordinatorDelegate: LoginCoordinatorDelegate { get }
    var biometryLoginView: BiometryLoginView? { get }
    var cancelAutomaticEvaluation: Bool { get set }
    var isLoginWithTouchIdEnabled: Bool { get set }
    var fingerprintAcceptedByUser: Bool { get set }
    var doBiometryAction: (() -> Void)? { get set }
    func getSessionCloseReason() -> SessionFinishedReason?
    func isSessionExpired() -> Bool
    func doBiometryLogin(with params: LoginParamViewModel)
    func isPbUser() -> Bool
    func failWithBiometryError(_ error: String)
    func willPromptBiometryAlert()
    func biometryAlertDidFinish()
}

extension BiometryLoginCapable {
    private var setTouchIdLoginDataUseCase: SetTouchIdLoginDataUseCase {
        self.dependenciesResolver.resolve(for: SetTouchIdLoginDataUseCase.self)
    }
    private var getTouchIdLoginDataUseCase: GetTouchIdLoginDataUseCase {
        return self.dependenciesResolver.resolve(for: GetTouchIdLoginDataUseCase.self)
    }
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var localAuthentication: LocalAuthenticationPermissionsManagerProtocol {
        return self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    private var pushNotificationExecutor: PushNotificationsExecutorProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: PushNotificationsExecutorProtocol.self)
    }
    private var universalLinkManager: UniversalLinkManagerProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: UniversalLinkManagerProtocol.self)
    }

    func handleBiometryError(_ errorType: LoginProcessLayerEvent.ErrorType) {
        switch errorType {
        case .biometricDeeplink, .biometricDocument, .biometricSecurity:
            self.setTouchIdLoginData(deviceMagicPhrase: nil,
                                     touchIDLoginEnabled: self.isLoginWithTouchIdEnabled) { [weak self] in
                self?.loadLoginType()
            }
        default:
            break
        }
    }
    
    func setTouchIdLoginData(deviceMagicPhrase: String?,
                             touchIDLoginEnabled: Bool?, completion: @escaping () -> Void) {
        let input = SetTouchIdLoginDataInput(deviceMagicPhrase: deviceMagicPhrase,
                                             touchIDLoginEnabled: touchIDLoginEnabled)
        UseCaseWrapper(with: self.setTouchIdLoginDataUseCase.setRequestValues(requestValues: input),
                         useCaseHandler: self.useCaseHandler,
                         onSuccess: { _ in
                          completion()
        })
    }
    
    func loadLoginType() {
        MainThreadUseCaseWrapper(
            with: self.getTouchIdLoginDataUseCase,
            onSuccess: { [weak self] (result) in
                guard let self = self else { return }
                let isBiometryEnabled = result.touchIdData.touchIDLoginEnabled &&
                                        !result.touchIdData.deviceMagicPhrase.isEmpty
                self.setLoginViewForAvailableBiometryType(
                    self.localAuthentication.biometryTypeAvailable,
                    isBiometryEnabled: isBiometryEnabled
                )
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.setLoginViewForAvailableBiometryType(
                    self.localAuthentication.biometryTypeAvailable,
                    isBiometryEnabled: false
                )
        })
    }
    
    func setLoginViewForAvailableBiometryType(_ biometryType: BiometryTypeEntity, isBiometryEnabled: Bool) {
        switch biometryType {
        case .touchId, .error(.touchId, .biometryNotEnrolled):
            self.biometryLoginView?.setAvailableBiometryType(fingerprintAcceptedByUser ? .none : .touchId)
            self.isLoginWithTouchIdEnabled = isBiometryEnabled
            if isBiometryEnabled {
                self.biometryLoginView?.displayLoginWithTouchIDView()
            } else {
                self.biometryLoginView?.displayLoginWithNumberPadView()
            }
        case .faceId, .error(.faceId, .biometryNotEnrolled):
            self.biometryLoginView?.setAvailableBiometryType(fingerprintAcceptedByUser ? .none : .faceId)
            self.isLoginWithTouchIdEnabled = isBiometryEnabled
            if isBiometryEnabled {
                self.biometryLoginView?.displayLoginWithFaceIDView()
            } else {
                self.biometryLoginView?.displayLoginWithNumberPadView()
            }
        case .none, .error:
            self.isLoginWithTouchIdEnabled = false
            self.biometryLoginView?.setAvailableBiometryType(.none)
            self.biometryLoginView?.displayLoginWithNumberPadView()
        }
    }
    
    func failedBiometric() {
        self.onTouchIdLoginFailure(localizedKey: "fingerprint_text_security")
    }
    
    func onTouchIdLoginFailure(localizedKey: String) {
        self.biometryLoginView?.dismissLoading(completion: { [weak self] in
            self?.setTouchIdLoginData(deviceMagicPhrase: nil, touchIDLoginEnabled: nil, completion: {
                self?.setLoginViewForAvailableBiometryType(.none, isBiometryEnabled: false)
                self?.biometryLoginView?.showLoginError(localized(localizedKey))
            })
        })
    }
    
    func automaticBiometryLogin(completion: @escaping () -> Void) {
        Scenario(useCase: getTouchIdLoginDataUseCase)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                switch self.localAuthentication.biometryTypeAvailable {
                case .touchId, .faceId:
                    if self.mustActiveBiometryLogin() {
                        self.showFingerPrintLoginIfPossible()
                    } else {
                        self.cancelAutomaticEvaluation = true
                    }
                default:
                    self.setLoginViewForAvailableBiometryType(
                        self.localAuthentication.biometryTypeAvailable,
                        isBiometryEnabled: result.touchIdData.touchIDLoginEnabled && !result.touchIdData.deviceMagicPhrase.isEmpty
                    )
                }
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.setLoginViewForAvailableBiometryType(
                    self.localAuthentication.biometryTypeAvailable,
                    isBiometryEnabled: false
                )
            }
            .finally(completion)
    }
    
    func mustActiveBiometryLogin() -> Bool {
        let closeReason = self.getSessionCloseReason()
        return !(closeReason == .logOut
              || closeReason == .timeoutInactivity
              || closeReason == .timeoutOutOfApp)
            && !self.cancelAutomaticEvaluation
            && !self.isSessionExpired()
            && self.isAppActive()
            && self.shouldActivateBiometricLoginDependingOnScheduledNotification()
            && self.shouldActivateBiometricLoginDependingOnUniversalLink()
    }
    
    func shouldActivateBiometricLoginDependingOnScheduledNotification() -> Bool {
        guard
            let notification = self.pushNotificationExecutor?.scheduledNotification(),
            let pushNotification = notification as? PushRequestable
        else {
            return true
        }
        // We have to deactivate the biometric login when we have ecommerce or otp notification scheduled
        return !self.isEcommerceNotification(pushNotification) && !self.isOtpNotification(pushNotification)
    }
    
    func isOtpNotification(_ notification: PushRequestable) -> Bool {
        return notification.executableType == .otp
    }
    
    func isEcommerceNotification(_ notification: PushRequestable) -> Bool {
        return notification.executableType == .custom(PushExecutableSpainCustomType.ecommerce)
    }
    
    func shouldActivateBiometricLoginDependingOnUniversalLink() -> Bool {
        guard let universalLinkManager = self.universalLinkManager else { return true }
        return !universalLinkManager.isNecessaryToLaunch
    }
    
    func isAppActive() -> Bool {
        return UIApplication.shared.applicationState == .active
    }
    
    func showFingerPrintLoginIfPossible() {
        // if the landing push is active, we have to schedule the fingerprint login action to the viewWillAppear event
        self.biometryLoginView?.isViewActive { [weak self] isActive in
            if isActive {
                self?.performBiometryAction()
            } else {
                self?.doBiometryAction = {
                    self?.performBiometryAction()
                    self?.doBiometryAction = nil
                }
            }
            
        }
    }
    
    func performBiometryAction() {
        self.biometryLoginView?.disableTouchIDView()
        switch self.localAuthentication.biometryTypeAvailable {
        case .faceId where !isLoginWithTouchIdEnabled, .touchId where !isLoginWithTouchIdEnabled:
            self.showBiometryActivationDialog()
        case .touchId:
            self.biometryLoginView?.displayLoginWithTouchIDView()
            self.fingerprintLogin()
        case .faceId:
            self.biometryLoginView?.displayLoginWithFaceIDView()
            self.fingerprintLogin()
        case .error(_, .biometryNotEnrolled):
            self.showBiometryActivationDialog()
        case .error(_, .biometryLockout):
            self.onTouchIdLoginFailure(localizedKey: "loginFingerprint_text_bloqued")
            self.failWithBiometryError(localized("loginFingerprint_text_bloqued").text)
            self.biometryLoginView?.enableTouchIDView()
        case .error(_, .biometryNotAvailable), .none:
            self.onTouchIdLoginFailure(localizedKey: "loginFingerprint_text_bloqued")
            self.failWithBiometryError(localized("loginFingerprint_text_bloqued").text)
        case .error:
            self.onTouchIdLoginFailure(localizedKey: "fingerprint_text_security")
            self.biometryLoginView?.enableTouchIDView()
        }
    }
    
    func showBiometryActivationDialog() {
        let completion: () -> Void = { [weak self] in
            self?.coordinatorDelegate.registerSecuritySettingsDeepLink()
            self?.biometryLoginView?.setAvailableBiometryType(.none)
            self?.biometryLoginView?.enableSideMenu()
            self?.fingerprintAcceptedByUser = true
        }
        let closeAction: () -> Void = { [weak self] in
            self?.biometryLoginView?.enableSideMenu()
        }
        
        self.biometryLoginView?.disableSideMenu()
        switch localAuthentication.biometryTypeAvailable {
        case .touchId, .error(.touchId, .biometryNotEnrolled):
            self.biometryLoginView?.showBiometryDialog(titleKey: "login_alertTitle_activateTouchId",
                                    descriptionKey: "login_alertText_activateTouchId",
                                    acceptKey: "login_button_activateTouchId",
                                    onAccept: completion,
                                    onClose: closeAction)
            self.failWithBiometryError(localized("login_alertText_activateTouchId").text)
        case .faceId, .error(.faceId, .biometryNotEnrolled):
            self.biometryLoginView?.showBiometryDialog(titleKey: "login_alertTitle_activateFaceId",
                                    descriptionKey: "login_alertText_activateFaceId",
                                    acceptKey: "login_button_activateFaceId",
                                    onAccept: completion,
                                    onClose: closeAction)
            self.failWithBiometryError(localized("login_alertText_activateFaceId").text)
        default: break
        }
    }
    
    func fingerprintLogin() {
        let reason = localized("touchId_alert_fingerprintLogin").text
        self.willPromptBiometryAlert()
        self.localAuthentication.evaluateBiometry(reason: reason, completion: { result in
            Async.main { [weak self] in
                switch result {
                case .success:
                    self?.biometryEvaluationResultSuccess()
                case .evaluationError(error: .appCancel):
                    self?.onTouchIdLoginFailure(localizedKey: "fingerprint_text_security")
                    self?.failWithBiometryError(localized("fingerprint_text_security").text)
                    self?.biometryLoginView?.enableTouchIDView()
                case .evaluationError(error: .authenticationFailed):
                    self?.onTouchIdLoginFailure(localizedKey: "fingerprint_text_security")
                    self?.failWithBiometryError(localized("fingerprint_text_security").text)
                    self?.biometryLoginView?.enableTouchIDView()
                case .evaluationError(error: .userCancel):
                    self?.cancelAutomaticEvaluation = true
                    self?.biometryLoginView?.enableTouchIDView()
                case .evaluationError(error: .biometricOutOfDate):
                    self?.biometricOutOfDate()
                case .evaluationError(error: .unknown):
                    self?.biometricUnknown()
                case .evaluationError(error: .systemCancel):
                    // This case happens when:
                    // - An app appears while biometry is evaluated
                    // - Another biometry dialog is invoked
                    self?.biometryLoginView?.enableTouchIDView()
                default:
                    self?.biometryLoginView?.enableTouchIDView()
                }
                self?.biometryAlertDidFinish()
            }
        }
        )
    }
    
    func biometryEvaluationResultSuccess() {
        UseCaseWrapper(
            with: self.getTouchIdLoginDataUseCase,
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] (result) in
                guard let self = self else { return }
                let param = LoginParamViewModel(
                    isBiometric: true,
                    biometricToken: result.touchIdData.deviceMagicPhrase,
                    footprint: result.touchIdData.footprint,
                    isPb: self.isPbUser(), password: ""
                )
                self.doBiometryLogin(with: param)
            }, onError: { [weak self] _ in
                self?.onTouchIdLoginFailure(localizedKey: "fingerprint_text_security")
                self?.biometryLoginView?.enableTouchIDView()
        })
    }
    
    func biometricOutOfDate() {
        let error = self.localAuthentication.biometryTypeAvailable == .faceId ?
            "loginBiometry_text_faceIdChanged": "loginBiometry_text_touchIdChanged"
        self.onTouchIdLoginFailure(localizedKey: error)
        self.failWithBiometryError(localized(error).text)
        self.biometryLoginView?.enableTouchIDView()
    }
    
    func biometricUnknown() {
        if case .error(_, error: BiometryErrorEntity.biometryLockout) = self.localAuthentication.biometryTypeAvailable {
            self.onTouchIdLoginFailure(localizedKey: "loginFingerprint_text_bloqued")
        }
        self.failWithBiometryError("")
        self.biometryLoginView?.enableTouchIDView()
    }
}
