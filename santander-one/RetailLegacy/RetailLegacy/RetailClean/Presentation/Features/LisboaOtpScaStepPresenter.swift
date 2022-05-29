import CoreFoundationLib
import Foundation

final class LisboaOtpScaStepPresenter: OperativeStepPresenter<LisboaGenericOtpViewController, ProductHomeNavigatorProtocol, GenericOtpPresenterProtocol> {
    var validation: OTPValidation?
    var operativeConfig: OperativeConfig?
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    override var screenId: String? {
        return container?.operative.screenIdOtp
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersOTP()
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        guard let container = container else {
            return
        }
        let otp: OTP = container.provideParameter()
        switch otp {
        case .userExcepted:
            executeOtpExcepted(container: container, onSuccess: onSuccess, onError: onError)
        case .validation(let validation):
            if validation.otpExcepted {
                executeOtpExcepted(container: container, onSuccess: onSuccess, onError: onError)
            } else {
                self.validation = validation
                LoadingCreator.hideGlobalLoading {
                    onSuccess(true)
                }
            }
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.setupViews()
        self.otpPushManager?.registerOtpHandler(handler: self)
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
}

extension LisboaOtpScaStepPresenter: GenericOtpDelegate {
    
    var operativeStepPresenter: OperativeStepPresenterProtocol {
        return self
    }
    
    func hideOtpLoading(completion: @escaping () -> Void) {
        hideAllLoadings(completion: completion)
    }
    
    func updateOtpLoading(text: LoadingText) {
        if let loading = getLoading() {
            loading.setText(text: text)
        } else {
            LoadingCreator.setLoadingText(loadingText: text)
        }
    }
    
    func showOtpError(keyDesc: String?, completion: @escaping () -> Void) {
        showError(keyDesc: keyDesc, completion: completion)
    }
    
    var errorOtpHandler: GenericPresenterErrorHandler {
        return self.genericErrorHandler
    }
}

extension LisboaOtpScaStepPresenter: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code, !otpCode.isEmpty else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        view.updateText(otpCode)
        view.enableAcceptButton()
    }
}

extension LisboaOtpScaStepPresenter: GenericOtpPresenterProtocol {
    func close() {
        self.dismiss()
    }
    
    var supportPhone: String? {
        guard let container = container else { return nil }
        let operativeConfig: OperativeConfig = container.provideParameter()
        guard let supportPhone = operativeConfig.otpSupportPhone, !supportPhone.isEmpty else { return nil }
        
        return supportPhone
    }
    
    var maxLength: Int {
        return 8
    }
    
    var characterSet: CharacterSet {
        return CharacterSet.signature
    }
    
    var showsHelpButton: Bool {
        false
    }
    
    func validateOtp() {
        guard let container = container else { return }
        self.showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil, completion: {
            container.saveParameter(parameter: OTPFilled(validation: self.validation, value: self.view.valueFromTextField()))
            container.operative.performOTP(for: self, completion: { [weak self] (result, error) in
                self?.hideLoading(completion: {
                    if result {
                        guard let thisPresenter = self else {
                            return
                        }
                        container.stepFinished(presenter: thisPresenter)
                    } else {
                        guard let dialog = self?.handle(error: error) else {
                            return
                        }
                        self?.showError(keyTitle: dialog.titleKey, keyDesc: dialog.descriptionKey, phone: self?.supportPhone, completion: dialog.acceptAction)
                    }
                })
            })
        })
    }
    
    func helpButtonTouched() {
        if let supportPhone = supportPhone {
            let titleOTP = stringLoader.getString("otp_titlePopup_notReceived")
            let bodyOTP = stringLoader.getString("otp_text_popup_notReceived", [StringPlaceholder(StringPlaceholder.Placeholder.phone, supportPhone)])
            let components = DialogButtonComponents(titled: stringLoader.getString("generic_button_understand"),
                                                    does: nil)
            Dialog.alert(title: titleOTP,
                         body: bodyOTP,
                         rightButton: components,
                         leftButton: nil,
                         source: view,
                         shouldTriggerHaptic: true)
        } else {
            Dialog.alert(title: stringLoader.getString("otp_titlePopup_notReceived"),
                         body: stringLoader.getString("otp_alert_retry"),
                         rightButton: DialogButtonComponents(titled: stringLoader.getString("generic_button_understand"),
                                                             does: nil),
                         leftButton: nil,
                         source: view,
                         shouldTriggerHaptic: true)
        }
    }
    
    func dismiss() {
        navigator.dismiss()
    }
}
private extension LisboaOtpScaStepPresenter {
    func handle(error: GenericErrorOTPErrorOutput?) -> OperativeContainerDialog {
        container?.operative.trackErrorEvent(page: screenId, error: error?.getErrorDesc(), code: error?.errorCode)
        guard let container = container, let errorType = error else { return .empty }
        var keyTitle = ""
        var errorDesc = error?.getErrorDesc()
        var acceptAction = {}
        
        switch errorType.otpResult {
        case .wrongOTP:
            keyTitle = "otp_titlePopup_error"
            errorDesc = "otp_text_popup_error"
            acceptAction = { self.view.cleanTextField() }
            HapticTrigger.alert()
        case .ok:
            container.stepFinished(presenter: self)
        case .otherError(let errorMessage):
            let keyTitle = ""
            let errorDesc = errorMessage
            acceptAction = { container.onSignatureError() }
            HapticTrigger.alert()
        case .serviceDefault:
            acceptAction = { container.onSignatureError() }
            HapticTrigger.operativeError()
        }
        return OperativeContainerDialog(titleKey: keyTitle, descriptionKey: errorDesc, acceptAction: acceptAction)
    }
    
    func executeOtpExcepted(container: OperativeContainerProtocol, onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        container.saveParameter(parameter: OTPFilled.empty)
        container.operative.performOTP(for: self, completion: { (result, error) in
            LoadingCreator.hideGlobalLoading(completion: {
                if !result {
                    onError(self.handle(error: error))
                } else {
                    onSuccess(false)
                }
            })
        })
    }
}
