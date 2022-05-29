import CoreFoundationLib
import ESCommons

protocol EcommercePresenterProtocol {
    var view: EcommerceViewProtocol? { get set }
    func viewDidLoad()
    func didFinishTimerInProgressView()
    func didTapInMoreInfo()
    func didTapInDismiss(_ completion: (() -> Void)?)
    func didTapInUseKeyAccess()
    func didTapInCancel()
    func confirmEcommerce(_ type: EcommerceFooterType)
    func didTapInTryAgainInShop()
    func viewWillAppear()
    func didTapInOpinator(_ path: String)
}

extension EcommercePresenterProtocol {
    func didTapInDismiss(_ completion: (() -> Void)? = nil) {
        self.didTapInDismiss(completion)
    }
}

final class EcommercePresenter {
    weak var view: EcommerceViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var lastPurchaseInfo: EcommerceLastPurchaseInfo?
    private var biometryData: TouchIdData?
    private var successTimer: Timer?
    private var showedOpinator: Bool = false
    var ticketContentType: EcommerceTicketContentType?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var configuration: EcommerceConfiguration {
        return self.dependenciesResolver.resolve(for: EcommerceConfiguration.self)
    }
    
    var input: EcommerceInput {
        return self.dependenciesResolver.resolve(for: EcommerceInput.self)
    }
}

extension EcommercePresenter: EcommercePresenterProtocol {
    func viewWillAppear() {
        if self.showedOpinator {
            self.getSuccessTimer()
            self.showedOpinator = false
        } else {
            guard configuration.accessKeyCode != nil else { return }
            self.onSuccessWithAccessKey()
        }
    }
    
    func viewDidLoad() {
        loadEcommerce()
        trackScreen()
    }
    
    // MARK: Actions
    func didFinishTimerInProgressView() {
        guard case .ticket(let configuration) = self.ticketContentType else { return }
        configuration.purchaseStatus = .expired
        configuration.showsCodeKeyButton = false
        self.view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: .tryAgainInShop)
    }
    
    func didTapInMoreInfo() {
        trackEvent(.knowMoreButton, parameters: [:])
        coordinator.moreInfo()
    }
    
    func didTapInDismiss() {
        self.coordinator.dismiss()
    }
    
    func didTapInUseKeyAccess() {
        self.coordinator.goToNumberPad()
    }
    
    func didTapInCancel() {
        self.coordinator.dismiss()
    }
    
    func didTapInDismiss(_ completion: (() -> Void)?) {
        self.coordinator.dismiss(completion)
    }
    
    func confirmEcommerce(_ type: EcommerceFooterType) {
        switch type {
        case .confirmBy(let type):
            switch type {
            case .code:
                self.coordinator.goToNumberPad()
            case .faceId, .fingerPrint:
                evaluateBiometryAccess()
            }
        case .useCodeAccess:
            self.coordinator.goToNumberPad()
        case .emptyView, .processingPayment, .tryAgainInShop, .restorePassword:
            break
        }
    }
    
    func didTapInTryAgainInShop() {
        self.coordinator.dismiss()
    }
    
    func didTapInOpinator(_ path: String) {
        let opinator = RegularOpinatorInfoEntity(path: path)
        self.coordinatorDelegate.handleOpinator(opinator)
        self.successTimer?.invalidate()
        self.showedOpinator = true
    }
}

private extension EcommercePresenter {
    var coordinator: EcommerceCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: EcommerceCoordinatorDelegate.self)
    }
    
    var coordinatorDelegate: EcommerceMainModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: EcommerceMainModuleCoordinatorDelegate.self)
    }
    
    var touchIdDataUseCase: GetTouchIdLoginDataUseCase {
        return dependenciesResolver.resolve(for: GetTouchIdLoginDataUseCase.self)
    }
    
    var setTouchIdLoginDataUseCase: SetTouchIdLoginDataUseCase {
        return dependenciesResolver.resolve(for: SetTouchIdLoginDataUseCase.self)
    }
    
    var getTokenPushUseCase: GetLocalPushTokenUseCase {
        self.dependenciesResolver.resolve(for: GetLocalPushTokenUseCase.self)
    }
    
    var ecommerceGetLastOperationUseCase: EcommerceGetLastOperationUseCase {
        self.dependenciesResolver.resolve(for: EcommerceGetLastOperationUseCase.self)
    }
    
    var ecommerceGetOperationDataUseCase: EcommerceGetOperationDataUseCase {
        self.dependenciesResolver.resolve(for: EcommerceGetOperationDataUseCase.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    
    func loadEcommerce() {
        view?.updateTicketView(.loading, containerType: .loading, footerType: .emptyView)
        self.getTouchIdData()
    }
    
    func getTouchIdData() {
        Scenario(useCase: touchIdDataUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] response in
                self?.biometryData = response.touchIdData
            }
            .finally(getInfoPushNotification)
    }
    
    func getInfoPushNotification() {
        let originSection = self.configuration.section
        switch originSection {
        case .mainDefault,
             .mainPushNotification where input.lastPurchaseCode == nil:
            self.evaluateSecureDeviceAccess()
        case .mainPushNotification:
            self.getEcommercePushNotification()
        case .fintechTPPConfirmation:
            break
        }
    }
    
    func getEcommercePushNotification() {
        guard let code = input.lastPurchaseCode else { return }
        self.lastPurchaseInfo = EcommerceLastPurchaseInfo(code: code, remainingTime: nil)
        self.getEcommerceOperationData()
    }
    
    func getEcommerceOperationData() {
        guard let lastPurchaseInfo = self.lastPurchaseInfo else {
            self.view?.updateTicketView(.content, containerType: .errorData(reason: nil), footerType: .emptyView)
            return
        }
        let input = EcommerceGetOperationDataUseCaseInput(ecommerceLastOperationCode: lastPurchaseInfo.code)
        Scenario(useCase: ecommerceGetOperationDataUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] operationDataResponse in
                guard let self = self else { return }
                self.loadTicketView(operationDataResponse.ecommerceData)
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateTicketView(.content, containerType: .errorData(reason: nil), footerType: .emptyView)
            }
    }
    
    func getLastOperationUseCase(_ output: GetLocalPushTokenUseCaseOkOutput) -> Scenario<EcommerceGetLastOperationUseCaseInput, EcommerceGetLastOperationUseCaseOutput, StringErrorOutput> {
        let input = EcommerceGetLastOperationUseCaseInput(tokenPush: output.tokenPush)
        return Scenario(useCase: self.ecommerceGetLastOperationUseCase, input: input)
    }
    
    // MARK: - View Configurations
    func loadTicketView(_ ecommerceData: EcommerceOperationDataEntity) {
        let date = currentLocaleDate()
        let viewModel = EcommerceViewModel(ecommerceData: ecommerceData, date: date, remainingTime: self.lastPurchaseInfo?.remainingTime)
        let authType = ecommerceAuthType
        let footerType: EcommerceFooterType = .confirmBy(authType)
        let opinatorViewModel = OpinatorViewModel(description: "ecommerce_label_recommendUsingSanKey",
                                                  opinatorPath: "APP-RET-sca-ecomm-SUCCESS-ES",
                                                  accessibilityOfView: "ecommerceBtnRecommendUsingSanKey")
        let configuration = EcommerceTicketContainerConfiguration(viewModel,
                                                                  confirmType: authType,
                                                                  confirmStatus: .confirmed,
                                                                  opinatorViewModel: opinatorViewModel)
        self.ticketContentType = .ticket(configuration)
        view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: footerType)
    }
    
    func currentLocaleDate() -> Date {
        let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
        return timeManager.getCurrentLocaleDate(inputDate: Date()) ?? Date()
    }
}

// MARK: - Biometry extension
private extension EcommercePresenter {
    var ecommerceAuthType: EcommerceAuthType {
        guard self.biometryData?.touchIDLoginEnabled == true else { return .code }
        switch biometricsManager.biometryTypeAvailable {
        case .error(biometry: .touchId, error: .unknown),
             .error(biometry: .faceId, error: .unknown),
             .error(biometry: .touchId, error: .biometryNotAvailable),
             .error(biometry: .faceId, error: .biometryNotAvailable):
            return .code
        case .touchId, .error(.touchId, _):
            return .fingerPrint
        case .faceId, .error(.faceId, _):
            return .faceId
        case .none, .error:
            return .code
        }
    }
    
    var ecommerceAuthMessage: String {
        switch biometricsManager.biometryTypeAvailable {
        case .touchId:
            return "touchId_alert_fingerprintLogin"
        default:
            return ""
        }
    }
    
    func evaluateBiometryAccess() {
        biometricsManager.evaluateBiometry(reason: localized(ecommerceAuthMessage)) { [weak self] resultEntity in
            Async.main { [weak self] in
                guard let self = self else { return }
                switch resultEntity {
                case .success:
                    self.onSuccessWithBiometry()
                case .evaluationError(error: .appCancel):
                    self.onTouchIdLoginFailure(reason: "fingerprint_text_security")
                case .evaluationError(error: .authenticationFailed):
                    self.onTouchIdLoginFailure(reason: "fingerprint_text_security")
                case .evaluationError(error: .biometricOutOfDate):
                    self.biometricOutOfDate()
                case .evaluationError(error: .unknown), .evaluationError(error: .systemCancel):
                    self.biometricCanceled()
                case .evaluationError(error: .userCancel):
                    break
                }
            }
        }
    }
    
    func biometricOutOfDate() {
        let error = self.ecommerceAuthType == .faceId ?
            "loginBiometry_text_faceIdChanged": "loginBiometry_text_touchIdChanged"
        self.onTouchIdLoginFailure(reason: error)
    }
    
    func biometricCanceled() {
        if case .error(_, error: BiometryErrorEntity.biometryLockout) = self.biometricsManager.biometryTypeAvailable {
            self.onTouchIdLoginFailure(reason: "loginFingerprint_text_bloqued")
        }
    }
    
    func onTouchIdLoginFailure(reason: String) {
        Scenario(
            useCase: setTouchIdLoginDataUseCase,
            input: SetTouchIdLoginDataInput(deviceMagicPhrase: nil, touchIDLoginEnabled: nil)
        )
        .execute(on: useCaseHandler)
        .onSuccess { [weak self] in
            guard let self = self else { return }
            guard case .ticket(let configuration) = self.ticketContentType else { return }
            configuration.confirmStatus = .notConfirmed
            configuration.confirmType = self.ecommerceAuthType
            self.biometryData = nil
            self.view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: .useCodeAccess)
            self.view?.showLoginError(localized(reason))
        }
    }
}

// MARK: - Confirmation extension
private extension EcommercePresenter {
    // MARK: - Purchase Status Functions
    func purchaseIdentifying() {
        guard case .ticket(let configuration) = ticketContentType else { return }
        configuration.confirmStatus = .confirmed
        configuration.purchaseStatus = .identifying
        configuration.showsCodeKeyButton = false
        self.view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: .processingPayment)
    }
    
    func purchaseSuccess(_ metric: EcommercePage.Action) {
        self.trackEvent(metric, parameters: [:])
        guard case .ticket(let configuration) = self.ticketContentType else {
            return
        }
        configuration.purchaseStatus = .success
        configuration.showsCodeKeyButton = false
        self.view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: .emptyView)
        self.successTimer = getSuccessTimer()
    }
    
    func purchaseError(message: String?, metric: EcommercePage.Action) {
        self.trackEvent(metric, parameters: [:])
        guard case .ticket(let configuration) = self.ticketContentType else {
            return
        }
        configuration.purchaseStatus = .errorConfirmation(message ?? "ecommerce_label_error")
        configuration.showsCodeKeyButton = false
        self.view?.updateTicketView(.content, containerType: .ticket(configuration), footerType: .emptyView)
    }
    
    // MARK: - Purchase by Biometry
    var confirmWithBiometryUseCase: EcommerceConfirmWithBiometryUseCase {
        return dependenciesResolver.resolve(for: EcommerceConfirmWithBiometryUseCase.self)
    }
    
    func onSuccessWithBiometry() {
        self.purchaseIdentifying()
        self.confirmByBiometry()
    }
    
    func confirmByBiometry() {
        guard let biometryData = biometryData,
              let code = lastPurchaseInfo?.code
        else { return }
        Scenario(
            useCase: confirmWithBiometryUseCase,
            input: EcommerceConfirmWithBiometryUseCaseInput(
                shortUrl: code,
                fingerprint: biometryData.footprint,
                deviceToken: biometryData.deviceMagicPhrase
            )
        )
        .execute(on: useCaseHandler)
        .onSuccess(onConfirmationBiometrySuccess)
        .onError(onConfirmationBiometryError)
    }
    
    func onConfirmationBiometrySuccess() {
        self.purchaseSuccess(.confirmBiometryOk)
    }
    
    func getErrorDesc(_ error: UseCaseError<StringErrorOutput>) -> String? {
        switch error {
        case .error(let error):
            return error?.getErrorDesc()
        case .generic, .intern, .unauthorized:
            return nil
        case .networkUnavailable:
            return "generic_error_withoutConnection"
        }
    }
    
    func onConfirmationBiometryError(_ error: UseCaseError<StringErrorOutput>) {
        self.purchaseError(message: getErrorDesc(error), metric: .confirmBiometryError)
    }
    
    // MARK: - Purchase by Access Key
    
    var confirmWithAccessKeyUseCase: EcommerceConfirmWithAccessKeyUseCase {
        return dependenciesResolver.resolve(for: EcommerceConfirmWithAccessKeyUseCase.self)
    }
    
    func onSuccessWithAccessKey() {
        self.purchaseIdentifying()
        self.confirmByAccessKey()
    }
    
    func confirmByAccessKey() {
        guard
            let code = lastPurchaseInfo?.code,
            let accessKeyCode = configuration.accessKeyCode else { return }
        Scenario(
            useCase: confirmWithAccessKeyUseCase,
            input: EcommerceConfirmWithAccessKeyUseCaseInput(
                shortUrl: code,
                accessKey: accessKeyCode
            )
        )
        .execute(on: useCaseHandler)        
        .onSuccess(onConfirmationAccessKeySuccess)
        .onError(onConfirmationAccessKeyError)
    }
    
    func onConfirmationAccessKeySuccess() {
        self.purchaseSuccess(.confirmKeyAccessOk)
    }
    
    func onConfirmationAccessKeyError(_ error: UseCaseError<StringErrorOutput>) {
        self.purchaseError(message: getErrorDesc(error), metric: .confirmKeyAccessError)
    }
    
    func getSuccessTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: EcommerceModelConstants.maxSecondsOnSuccessView, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.showedOpinator = false
            self?.coordinator.dismiss()
        }
    }
}

extension EcommercePresenter: AutomaticScreenActionTrackable {
    var trackerPage: EcommercePage {
        EcommercePage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

// MARK: - Secure Device
private extension EcommercePresenter {
    var otpPushManager: OtpPushManagerProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }
    
    var sessionManager: CoreSessionManager {
        return self.dependenciesResolver.resolve(for: CoreSessionManager.self)
    }
    
    func evaluateSecureDeviceAccess() {
        if sessionManager.isSessionActive {
            checkSecureDeviceStatus()
        } else {
            checkSecureDeviceStatusLoginRemember()
        }
    }
    
    func checkSecureDeviceStatus() {
        otpPushManager?.updateToken(completion: { [weak self] _, state in
            if let state = state {
                switch state {
                case .rightRegisteredDevice:
                    self?.getEcommerceLastOperation()
                case .anotherRegisteredDevice:
                    self?.view?.showEmptyViewWithSecureDevice(
                        EcommerceSecureDeviceViewModel(secureDeviceTitle: "secureDevice_title_notYourDevice",
                                                       secureDeviceAction: "secureDevice_alert_button_updateSecurityDevice",
                                                       pageStrategy: EcommerceUpdateSantanderKeyPGPage())
                    )
                case .notRegisteredDevice:
                    self?.view?.showEmptyViewWithSecureDevice(
                        EcommerceSecureDeviceViewModel(secureDeviceTitle: "secureDevice_alert_title_waitingFor",
                                                       secureDeviceAction: "secureDevice_alert_button_registerSecurityDevice",
                                                       pageStrategy: EcommerceRegisterSantanderKeyPGPage())
                    )
                }
            } else {
                self?.view?.updateTicketView(.content, containerType: .errorData(reason: nil), footerType: .emptyView)
            }
        })
    }
    
    func checkSecureDeviceStatusLoginRemember() {
        Scenario(useCase: getTokenPushUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess({ [weak self] response in
                if response.tokenPush != nil {
                    self?.getEcommerceLastOperation()
                } else {
                    self?.view?.showEmptyViewWithSecureDevice(
                        EcommerceSecureDeviceViewModel(secureDeviceTitle: "secureDevice_alert_title_waitingFor",
                                                       secureDeviceAction: "secureDevice_alert_button_registerSecurityDevice",
                                                       pageStrategy: EcommerceRegisterSantanderKeyLoginRememberPage())
                    )
                }
            })
    }
    
    func getEcommerceLastOperation() {
        Scenario(useCase: getTokenPushUseCase)
            .execute(on: self.useCaseHandler)
            .then(scenario: self.getLastOperationUseCase)
            .onSuccess({ [weak self] response in
                guard let self = self else { return }
                self.view?.removeEmptyView()
                self.lastPurchaseInfo = response.lastPurchaseInfo
                self.getEcommerceOperationData()
            })
            .onError({ [weak self] error in
                guard let self = self else { return }
                switch error.getErrorDesc()?.uppercased() {
                case EcommerceModelConstants.errorCodeNotContent:
                    self.view?.showEmptyView()
                default:
                    self.view?.updateTicketView(.content, containerType: .errorData(reason: nil), footerType: .emptyView)
                }
            })
    }
}
