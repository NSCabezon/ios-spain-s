//
//  OTPPresenter.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 13/01/2020.
//

import Foundation
import CoreFoundationLib
import CorePushNotificationsService

public protocol OTPPresenterProtocol: OperativeStepPresenterProtocol {
    var view: OTPViewProtocol? { get set }
    var maxLength: Int { get }
    var characterSet: CharacterSet { get }
    var showsHelpButton: Bool { get }
    var supportPhone: String? { get }
    func validateOtp()
    func helpButtonTouched()
    func loaded()
    func viewDidLoad()
    func didTapClose()
    func didTapBack()
    func didSelectHelp()
}

final public class OTPPresenter {
    public weak var view: OTPViewProtocol?
    public var number: Int = 0
    public var container: OperativeContainerProtocol?
    public var isBackButtonEnabled: Bool = false
    public var isCancelButtonEnabled: Bool = false
    private var otpCapableOperative: OperativeOTPCapable? {
        self.container?.operative as? OperativeOTPCapable
    }
    private var faqsCapableOperative: OperativeFaqsCapable? {
        self.container?.operative as? OperativeFaqsCapable
    }
    public var supportPhone: String? {
        guard let container = container else { return nil }
        let operativeConfig: OperativeConfig = container.get()
        guard let supportPhone = operativeConfig.otpSupportPhone, !supportPhone.isEmpty else { return nil }
        return supportPhone
    }
    let dependencies: DependenciesResolver
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.dependencies.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    public init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
}

public enum OTPDialogType {
    public enum OTPGenericType {
        case genericOTPDialog
        case notRegisteredDeviceDialog
    }
    case genenic(type: OTPGenericType)
    case wrongOTP(error: GenericErrorOTPErrorOutput?, hasTitleAndNotAlignmentCenter: Bool?)
    case otherError(hasTitleNotAlignment: Bool?, errorMessage: String, action: () -> Void)
    case serviceDefault(error: GenericErrorOTPErrorOutput?, action: () -> Void)
    case expired(action: () -> Void)
    case revoked(action: () -> Void)
    case unknown
}

extension OTPPresenter {
    public var isBackable: Bool {
        return false
    }
}

extension OTPPresenter: OTPPresenterProtocol {
    public var showsHelpButton: Bool {
        return self.container?.operative as? OperativeFaqsCapable != nil
    }
    
    public func didTapClose() {
        self.container?.close()
    }
    
    public func didTapBack() {
        self.container?.back()
    }
    
    public var maxLength: Int {
        guard let otpConfiguration = self.dependencies.resolve(forOptionalType: OTPConfigurationProtocol.self) else {
            return 8
        }
        return otpConfiguration.maxlength
    }
    public var characterSet: CharacterSet {
        return CharacterSet.signature
    }
    
    public func viewDidLoad() {
        self.otpPushManager?.registerOtpHandler(handler: self)
        guard let trackerCapable = self.container?.operative as? OperativeTrackerCapable & OperativeOTPTrackerCapable & Operative else { return }
        let screenIdOtp = trackerCapable.screenIdOtp
        trackerCapable.trackScreen(screenId: screenIdOtp)
        if let navigationTitleCapable = self.container?.operative as? OperativeOTPNavigationCapable {
            view?.setNavigationBuilderTitle(navigationTitleCapable.otpNavigationTitle)
        } else {
            view?.setNavigationBuilderTitle(nil)
        }
        trackerCapable.trackScreen(screenId: screenIdOtp)
    }
    
    public func loaded() {
        self.view?.showLoading()
        let useCase = GetPhoneOTPUseCase(dependenciesResolver: self.dependencies)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.view?.dismissLoading {
                    switch result {
                    case .not:
                        self?.view?.setSubtitle(text: localized("otp_text_insertCodeWithoutPhone"))
                    case .push(let model):
                        self?.view?.setSubtitle(text: localized("otp_text_insertCodePush", [StringPlaceholder(.value, model)]))
                    case .sms(let phone):
                        self?.view?.setSubtitle(text: localized("otp_text_insertCode", [StringPlaceholder(.value, phone.substring(phone.count - 3, phone.count) ?? phone)]))
                    }
                    self?.view?.showKeyboard()
                }
            },
            onError: { [weak self] _ in
                self?.view?.dismissLoading {
                    self?.view?.setSubtitle(text: localized("otp_text_insertCodeWithoutPhone"))
                    self?.view?.showKeyboard()
                }
            }
        )
    }
    
    public func validateOtp() {
        guard let view = self.view else { return }
        view.showLoading()
        self.otpCapableOperative?.performOTP(for: view) { success, error in
            self.view?.dismissLoading {
                if success {
                    self.container?.stepFinished(presenter: self)
                } else {
                    self.handle(error: error)
                }
            }
        }
    }
    
    public func helpButtonTouched() {
        if let configuration = self.dependencies.resolve(forOptionalType: OTPConfigurationProtocol.self), !configuration.shouldResendCode {
            self.view?.showDialogForType(.genenic(type: .genericOTPDialog))
        } else {
            self.updateOTPToken()
        }
    }
    
    private func updateOTPToken() {
        view?.showLoading()
        self.otpPushManager?.updateToken { [weak self] _, returnCode in
            self?.view?.dismissLoading {
                guard let self = self else { return }
                switch returnCode {
                case .anotherRegisteredDevice:
                    self.view?.showDialogForType(.genenic(type: .notRegisteredDeviceDialog))
                case .rightRegisteredDevice, .notRegisteredDevice, .none:
                    self.view?.showDialogForType(.genenic(type: .genericOTPDialog))
                }
            }
        }
    }
    
    func handle(error: GenericErrorOTPErrorOutput?) {
        if let trackerCapable = self.container?.operative as? OperativeTrackerCapable & OperativeOTPTrackerCapable & Operative, let errorType = error {
            let screenIdOtp = trackerCapable.screenIdOtp
            trackerCapable.trackErrorEvent(page: screenIdOtp, error: errorType.getErrorDesc(), code: errorType.errorCode)
        }
        switch error?.otpResult {
        case .wrongOTP:
            let hasTitleNotAlignment = self.dependencies.resolve(forOptionalType: OTPConfigurationProtocol.self)?.hasTitleAndNotAlignmentCenter
            HapticTrigger.alert()
            self.view?.showDialogForType(.wrongOTP(error: error, hasTitleAndNotAlignmentCenter: hasTitleNotAlignment))
        case .correctOTP:
            container?.stepFinished(presenter: self)
        case .otherError(let errorMessage):
            let hasTitleNotAlignment = self.dependencies.resolve(forOptionalType: OTPConfigurationProtocol.self)?.hasTitleAndNotAlignmentCenter
            HapticTrigger.alert()
            self.view?.showDialogForType(.otherError(hasTitleNotAlignment: hasTitleNotAlignment, errorMessage: errorMessage, action: { self.container?.goToFirstOperativeStep() }))
        case .serviceDefault, .none:
            HapticTrigger.operativeError()
            self.view?.showDialogForType(.serviceDefault(error: error, action: { self.container?.goToFirstOperativeStep() }))
        case .otpExpired:
            self.view?.showDialogForType(.expired(action: { self.container?.back() }))
        case .otpRevoked:
            self.view?.showDialogForType(
                .revoked(action: { self.container?.dismissOperative() }))
        case .unknown: self.view?.showDialogForType(.unknown)
        }
    }
    
    func parseError(error: GenericErrorOTPErrorOutput?) -> OperativeSetupError? {
        switch error?.otpResult {
        case .wrongOTP:
            let keyTitle = "otp_titlePopup_error"
            let errorDesc = "otp_text_popup_error"
            HapticTrigger.alert()
            return OperativeSetupError(title: keyTitle, message: errorDesc)
        case .correctOTP:
            return nil
        case .serviceDefault, .otherError, .otpExpired, .otpRevoked, .unknown, .none:
            let keyTitle = ""
            let errorDesc = error?.getErrorDesc()
            HapticTrigger.operativeError()
            return OperativeSetupError(title: keyTitle, message: errorDesc)
        }
    }
    
    public func didSelectHelp() {
        guard let faqsCapable = faqsCapableOperative,
            let faqs = faqsCapable.infoHelpButtonFaqs
            else { return }
        self.view?.showFaqs(faqs)
    }
}

extension OTPPresenter: OtpNotificationHandler {
    public func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code, !otpCode.isEmpty else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        self.view?.updateText(otpCode)
        self.view?.enableAcceptButton()
    }
}
