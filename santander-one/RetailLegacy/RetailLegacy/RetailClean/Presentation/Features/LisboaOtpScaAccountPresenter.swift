import Foundation
import CoreFoundationLib
import Account

class LisboaOtpScaAccountPresenter: PrivatePresenter<LisboaGenericOtpViewController, OtpScaAccountNavigatorProtocol, GenericOtpPresenterProtocol> {
    private enum Constants {
        static let defaultOtpLength: Int = 8
    }
    private var validateSca: ValidateSca?
    private var otpPushDevice: OTPPushDevice?
    var shouldShowProgress: Bool {
        return true
    }
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    // MARK: - Public
    
    weak var delegate: OtpScaAccountPresenterDelegate?
    var scaTransactionParams: SCATransactionParams?
    
    override init(dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OtpScaAccountNavigatorProtocol) {
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        barButtons = [.close]
    }
    
    override func loadViewData() {
        super.loadViewData()
        self.otpPushManager?.registerOtpHandler(handler: self)
        getOTP(resend: false)
        view.setProgressBar(progress: Progress(totalUnitCount: 0))
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
}

extension LisboaOtpScaAccountPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        navigator.dismiss()
    }
}

extension LisboaOtpScaAccountPresenter: GenericOtpPresenterProtocol {
    func close() {
        self.dismiss()
    }
    
    var maxLength: Int {
        guard let otpConfiguration = self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: OTPConfigurationProtocol.self) else {
            return Constants.defaultOtpLength
        }
        return otpConfiguration.maxlength
    }
    
    var characterSet: CharacterSet {
        return .signature
    }
    
    var showsHelpButton: Bool {
        return false
    }
    
    func validateOtp() {
        guard let validateSca: ValidateSca = validateSca else {
            return
        }
        confirmSca(validateSca)
    }
    
    func helpButtonTouched() {
        getOTP(resend: true)
    }
    
    func dismiss() {
        self.cleanSCAInfo()
    }
}

private extension LisboaOtpScaAccountPresenter {
    func getOTP(resend: Bool) {
        let input: ValidateScaUseCaseInput = ValidateScaUseCaseInput(forwardIndicator: resend, forceSMS: resend, operativeIndicator: .accounts, scaTransactionParams: scaTransactionParams)
        showLoading()
        view.endEditing(false)
        UseCaseWrapper(
            with: useCaseProvider.getValidateScaUseCase().setRequestValues(requestValues: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    self?.otpPushDevice = response.otpPushDevice
                    self?.validateSca = response.validateSca
                    self?.setDescriptionText()
                    self?.view.otpTextField.becomeFirstResponder()
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    let completion: (() -> Void)?
                    let type: ValidateScaErrorType? = error?.type
                    switch type {
                    case .blacklist?:
                        completion = { [weak self] in
                            self?.navigator.dismiss()
                        }
                    case .serviceDefault?, .none:
                        completion = nil
                    }
                    self?.showError(keyTitle: nil, keyDesc: error?.getErrorDesc(), phone: nil, completion: completion)
                }
            }
        )
    }
    
    func confirmSca(_ validateSca: ValidateSca) {
        showLoading()
        let codeOTP: String = view.valueFromTextField()
        let input: ConfirmScaUseCaseInput = ConfirmScaUseCaseInput(operativeIndicator: .accounts, validateSca: validateSca, codeOTP: codeOTP, scaTransactionParams: scaTransactionParams)
        UseCaseWrapper(
            with: useCaseProvider.getConfirmScaUseCase().setRequestValues(requestValues: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] _ in
                self?.hideAllLoadings { [weak self] in
                    self?.delegate?.otpDidFinishSuccessfully()
                    self?.navigator.dismiss()
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let dialog = self?.handle(error: error) else {
                        return
                    }
                    self?.showError(
                        keyTitle: dialog.titleKey,
                        keyDesc: dialog.descriptionKey,
                        phone: nil,
                        completion: dialog.acceptAction
                    )
                }
            }
        )
    }
    
    func handle(error: ConfirmScaUseCaseErrorOutput?) -> OperativeContainerDialog? {
        guard let errorType = error else { return .empty }
        var keyTitle = ""
        var errorDesc = error?.getErrorDesc()
        var acceptAction = {}
        switch errorType.otpResult {
        case .timeoutOTP:
            keyTitle = ""
            errorDesc = "otp_text_passwordExpired"
            acceptAction = { self.navigator.dismiss() }
            HapticTrigger.alert()
        case .wrongOTP:
            keyTitle = "otp_titlePopup_error"
            errorDesc = "otp_text_popup_error"
            acceptAction = { self.view.cleanTextField() }
            HapticTrigger.alert()
        case .serviceDefault, .otherError:
            acceptAction = { self.navigator.dismiss() }
            HapticTrigger.operativeError()
        case .penalize:
            HapticTrigger.operativeError()
            let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_understand"), does: { self.navigator.dismiss() })
            Dialog.alert(title: localized(key: "otpSCA_alert_title_blocked"), body: localized(key: "otpSCA_alert_text_blocked"), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
            return nil
        }
        return OperativeContainerDialog(titleKey: keyTitle, descriptionKey: errorDesc, acceptAction: acceptAction)
    }
    
    func showLoading() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    private func setDescriptionText() {
        view.setSubtitle(text: localized(key: "otp_text_insertCodeWithoutPhone"))
    }
    
    func cleanSCAInfo() {
        guard let cleanScaUseCase = self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: CleanSCAInfoUseCaseProtocol.self) else {
            navigator.dismiss()
            return
        }
        Scenario(useCase: cleanScaUseCase)
            .execute(on: self.useCaseProvider.dependenciesResolver.resolve())
            .onSuccess({ [weak self] result in
                guard let self = self else { return }
                self.navigator.dismiss()
            })
    }
}

extension LisboaOtpScaAccountPresenter: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        view.updateText(otpCode)
        view.enableAcceptButton()
    }
}

extension LisboaOtpScaAccountPresenter: PresenterProgressBarCapable {}
