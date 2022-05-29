//
//  OtpScaLoginPresenter.swift
//  RetailClean
//
//  Created by Victor Carrilero García on 26/08/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import CoreDomain
import CoreFoundationLib
import Foundation

class OtpScaLoginPresenter: PrivatePresenter<OtpScaLoginViewController, OtpScaLoginNavigator, OtpScaLoginPresenterProtocol> {
    private let username: String
    private let isFirstTime: Bool
    private var validateSca: ValidateSca?
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    init(username: String, isFirstTime: Bool, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OtpScaLoginNavigator) {
        self.username = username
        self.isFirstTime = isFirstTime
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        barButtons = [.none]
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.set(acceptText: localized(key: "otpSCA_button_continue"))
        let titleText: LocalizedStylableText = stringLoader.getString("otpSCA_text_hello", [StringPlaceholder(StringPlaceholder.Placeholder.name, username.camelCasedString)])
        view.set(titleText: titleText)
        let subtitleText: LocalizedStylableText
        if isFirstTime {
            subtitleText = localized(key: "otpSCA_text_safety")
        } else {
            subtitleText = localized(key: "otpSCA_text_safety90")
        }
        view.set(subtitleText: subtitleText)
        view.set(infoText: localized(key: "otpSCA_text_insertCode"))
        view.setNormalImageInTitle()
        view.set(buttonRememberText: localized(key: "otpSCA_link_notCode"))
        view.set(maxLength: 8, characterSet: CharacterSet.signature)
        otpPushManager?.registerOtpHandler(handler: self)
        getOtp(resend: false)
    }
    
    // MARK: - Private methods
    
    private func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    private func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    private func handle(error: ConfirmScaUseCaseErrorOutput?) {
        let keyTitle: String?
        let errorDesc: String?
        let acceptAction: (() -> Void)?
        switch error?.otpResult {
        case .timeoutOTP?:
            keyTitle = nil
            errorDesc = "otp_text_passwordExpired"
            acceptAction = { self.navigator.close() }
            HapticTrigger.alert()
        case .wrongOTP?:
            keyTitle = "otp_titlePopup_error"
            errorDesc = "otp_text_popup_error"
            acceptAction = {
                self.view.cleanTextField()
            }
            HapticTrigger.alert()
        case .serviceDefault?, .otherError?:
            keyTitle = nil
            errorDesc = error?.getErrorDesc()
            acceptAction = nil
            HapticTrigger.operativeError()
        case .penalize?:
            keyTitle = "otpSCA_alert_title_blockedLogin"
            errorDesc = "otpSCA_alert_text_blockedLogin"
            acceptAction = { self.navigator.close() }
            HapticTrigger.alert()
        case .none:
            keyTitle = nil
            errorDesc = error?.getErrorDesc()
            acceptAction = nil
        }
        showError(keyTitle: keyTitle, keyDesc: errorDesc, phone: nil, completion: acceptAction)
    }
    
    private func getOtp(resend: Bool) {
        startOperativeLoading { [weak self] in
            guard let strongSelf = self else { return }
            let input: ValidateScaUseCaseInput = ValidateScaUseCaseInput(forwardIndicator: resend, forceSMS: resend, operativeIndicator: .login)
            UseCaseWrapper(with: strongSelf.useCaseProvider.getValidateScaUseCase().setRequestValues(requestValues: input), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] response in
                self?.hideOperativeLoading { [weak self] in
                    guard let strongSelf = self else { return }
                    let validateSca: ValidateSca = response.validateSca
                    strongSelf.validateSca = validateSca
                    strongSelf.view.focusTextField()
                }
                }, onError: { [weak self] error in
                    self?.hideOperativeLoading { [weak self] in
                        let completion: (() -> Void)?
                        let type: ValidateScaErrorType? = error?.type
                        switch type {
                        case .blacklist?:
                            completion = { [weak self] in
                                self?.close()
                            }
                        case .serviceDefault?, .none:
                            completion = nil
                        }
                        self?.showError(keyTitle: nil, keyDesc: error?.getErrorDesc(), phone: nil, completion: completion)
                    }
            })
        }
    }
    
    private func handleLoadSessionDataSuccess() {
        self.sessionManager.sessionStarted(completion: nil)
        UseCaseWrapper(with: useCaseProvider.getUserPreferencesEntityUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            self?.navigator.advance(globalPositionOption: result.userPref?.globalPositionOnboardingSelected() ?? .classic)
            }, onError: { [weak self] _ in
                self?.navigator.advance(globalPositionOption: GlobalPositionOptionEntity.classic)
        })
    }
}

extension OtpScaLoginPresenter: OtpScaLoginPresenterProtocol {
    func validateOtp() {
        guard let validateSca: ValidateSca = self.validateSca else {
            return
        }
        startOperativeLoading { [weak self] in
            guard let strongSelf = self else { return }
            let codeOTP: String = strongSelf.view.valueFromTextField()
            let input: ConfirmScaUseCaseInput = ConfirmScaUseCaseInput(operativeIndicator: .login, validateSca: validateSca, codeOTP: codeOTP)
            UseCaseWrapper(with: strongSelf.useCaseProvider.getConfirmScaUseCase().setRequestValues(requestValues: input), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] _ in
                self?.hideOperativeLoading { [weak self] in
                    self?.handleLoadSessionDataSuccess()
                }
                }, onError: { [weak self] error in
                    self?.hideOperativeLoading { [weak self] in
                        self?.handle(error: error)
                    }
            })
        }
    }
    
    func close() {
        checkHasPersistedUser()
    }
    
    func resend() {
        getOtp(resend: true)
    }
}

extension OtpScaLoginPresenter: PersistedUserCheckable {}

extension OtpScaLoginPresenter: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code, !otpCode.isEmpty else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        view.updateText(otpCode)
        view.enableAcceptButton()
    }
}
