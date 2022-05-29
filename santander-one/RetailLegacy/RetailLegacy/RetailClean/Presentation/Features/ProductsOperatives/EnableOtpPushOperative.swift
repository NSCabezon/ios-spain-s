import CoreFoundationLib
import Foundation

final class EnableOtpPushOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var opinatorPage: OpinatorPage? {
        return nil
    }
    
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.otpPushOperativeFinishedNavigator
    }
    
    let dependencies: PresentationComponent
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.OtpPushOperativeSignature().page
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.OtpPushOperativeOTP().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.OtpPushOperativeSummary().page
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as ChangeAliasOtpPushStep)
        add(step: factory.createStep() as LisboaSignatureWithToken)
        add(step: factory.createStep() as SecureDeviceOTPStep)
        add(step: factory.createStep() as SummaryOtpPushStep)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let usecase = dependencies.useCaseProvider.getPreSetupEnableOtpPushUseCase()
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { [weak self] _ in
            guard let strongSelf = self,
                  let permissionsManager = strongSelf.notificationPermissionsManager
            else { return completion(false, nil) }
            strongSelf.notificationPermissionsManager?.isNotificationsEnabled { (isEnabled) in
                Async.main {
                    guard
                        isEnabled,
                        let otpPushManager = strongSelf.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager(),
                        let deviceToken = otpPushManager.getDeviceToken()
                        else { return completion(false, (title: "managementPermission_label_permission", message: "otpPush_alert_notificationsPermission")) }
                    
                    var operativeData: EnableOtpPushOperativeData = container.provideParameter()
                    operativeData.tokenPush = deviceToken
                    container.saveParameter(parameter: operativeData)
                    completion(true, nil)
                }
            }
            }, onError: { _ in
                completion(false, nil)
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        var operativeData: EnableOtpPushOperativeData = container.provideParameter()
        let useCase = dependencies.useCaseProvider.getSetupEnableOtpPushUseCase(input: SetupEnableOtpPushUseCaseInput(isAnyDeviceRegistered: operativeData.isAnyDeviceRegistered))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            container.saveParameter(parameter: result.operativeConfig)
            operativeData.operativeMode = result.operativeMode
            container.saveParameter(parameter: operativeData)
            success()
        }, onError: { _ in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: "generic_alert_notAvailableTemporarilyOperation", completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        let confirmData = ConfirmEnableOtpPushUseCaseInput(signature: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getConfirmEnableOtpPushUseCase(input: confirmData)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter,
                       onSuccess: { [weak self] response in
                        self?.container?.saveParameter(parameter: response.otp)
                        completion(true, nil)
            },
                       onError: { error in
                        completion(false, error)
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        var data: EnableOtpPushOperativeData = containerParameter()
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        var validation = otpFilled.validation
        let otpCode = otpFilled.value ?? ""
        if validation == nil {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
        guard let otpValidation = validation, let tokenPush = data.tokenPush else {
            completion(false, nil)
            return
        }
        let inputData = ConfirmOTPEnableOtpPushUseCaseInput(alias: data.alias, language: dependencies.stringLoader.getCurrentLanguage(), otpValidation: otpValidation, otpCode: otpCode, tokenPush: tokenPush)
        let useCase = dependencies.useCaseProvider.getConfirmOTPEnableOtpPushUseCase(input: inputData)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { [weak self] result in
                data.deviceModel = result.deviceModel
                self?.container?.saveParameter(parameter: data)
                defer {
                    completion(true, nil)
                }
                self?.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.OtpPushRegister().page, eventId: TrackerPagePrivate.Generic.Action.ok.rawValue, extraParameters: [:])
                self?.registerTwinPushAndSaveToken(deviceId: result.deviceId)
            },
            onError: { error in
                var parameters: [String: String] = [:]
                if let errorDesc = error?.getErrorDesc() {
                    parameters[TrackerDimensions.descError] = errorDesc
                }
                if let errorCode = error?.errorCode {
                    parameters[TrackerDimensions.codError] = errorCode
                }
                self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.OtpPushRegister().page, eventId: TrackerPagePrivate.Generic.Action.error.rawValue, extraParameters: parameters)
                completion(false, error)
        }
        )
    }
    
    func registerTwinPushAndSaveToken(deviceId: String) {
        let managerBridge = self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)
        let otpPushManager = managerBridge?.getOtpPushManager()
        otpPushManager?.registerOtpPushAndSaveToken(deviceId: deviceId)
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_deviceRightRegister")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else { return nil }
        
        let operativeData: EnableOtpPushOperativeData = container.provideParameter()
        var data: [SummaryItemData] = []
        
        if let deviceModel = operativeData.deviceModel {
            data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_terminal"), value: deviceModel))
        }
        
        if let alias = operativeData.alias, !alias.isEmpty {
            data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_alias"), value: alias))
        }
        
        data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_registrationDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? ""))
        
        return data
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_globalPosition")
    }
}

extension EnableOtpPushOperative: RegisteringOtpPushCapable {
    
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
        
    }
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
}

struct ChangeAliasOtpPushStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.enableOtpPushChangeAliasPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct SummaryOtpPushStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = false
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.secureDeviceSummaryPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct SecureDeviceOTPStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        let presenter = presenterProvider.secureDeviceOtpPresenter
        return presenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
