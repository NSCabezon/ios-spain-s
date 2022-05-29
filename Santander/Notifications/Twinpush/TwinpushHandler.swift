//
//  TwinpushHandler.swift
//  Santander
//
//  Created by Marcos Álvarez Mesa on 20/4/21.
//

import CoreFoundationLib
import TwinPushSDK
import RetailLegacy
import ESCommons

public final class TwinpushHandler: NSObject {
    let dependenciesResolver: DependenciesResolver
    private var timeManager: TimeManager?
    private let compilation: SpainCompilationProtocol
    private var lastPush: SPPushNotification?
    private var deviceToken: Data?
    private weak var otpHandler: OtpNotificationHandler?
    private weak var notificationProcessorDelegate: NotificationProcessorProtocol?
    private lazy var removeOtpPushNotificationsUseCase: RemoveOtpPushNotificationUseCase = {
        return RemoveOtpPushNotificationUseCase(dependenciesResolver: self.dependenciesResolver)
    }()
    private var shared: TwinPushManager {
        return TwinPushManager.singleton()
    }
    private var completionUpdateToken: ((_ isNew: Bool, _ returnCode: ReturnCodeOTPPush?) -> Void)?
    private var isWaitingToUpdateToken: Bool = false

    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: SpainCompilationProtocol.self)
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }

    func setConfiguration(timeManager: TimeManager) {
        self.timeManager = timeManager
    }

    func setup(deviceId: String?) {
        shared.autoRegisterForRemoteNotifications = false
        shared.externalRegisterBlock = { _, onComplete in
            let device = TPDevice()
            device.deviceId = deviceId ?? self.getDeviceId()
            onComplete?(device)
        }
        shared.serverSubdomain = compilation.twinPushSubdomain
        let password = DomainConstant.K2 + DomainConstant.K0 + DomainConstant.K1
        guard
            let appID = compilation.twinPushAppId.decrypt(keyString: password),
            let apiKey = compilation.twinPushApiKey.decrypt(keyString: password) else {
                return
        }
        shared.setupTwinPushManager(withAppId: appID, apiKey: apiKey, delegate: self)
    }

    func setAlias(_ alias: String?) {
        shared.alias = alias
    }

    func setProperty(_ property: String, value: String?) {
        shared.setProperty(property, withStringValue: value)
    }

    // Only enabled to the remote notifications in background mode
    func didReceiveRemoteNotification(_ application: UIApplication, userInfo: [AnyHashable: Any]) {
        shared.application(application, didReceiveRemoteNotification: userInfo)
    }

    func getDeviceId() -> String? {
        return shared.deviceId
    }
    
    func getDeviceToken() -> String? {
        return shared.pushToken
    }
}

extension TwinpushHandler: NotificationDeviceInfoProvider {
    public func getVersionNumber() -> String? {
        return shared.versionNumber
    }    

    public func getDeviceUDID() -> String? {
        return shared.deviceUDID
    }
    
    public func getDeviceID() -> String? {
        return shared.deviceId
    }
}

extension TwinpushHandler: TwinPushManagerDelegate {
    public func didFinishRegisteringDevice() {
        shared.setProperty("app_version", withEnumValue: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
    }
}

// MARK: - NotificationResponseCapable
extension TwinpushHandler: NotificationResponseCapable {
    public func willPresentPushWIthInfo(_ info: SPPushNotification,
                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.lastPush = info
        self.notificationProcessorDelegate?.willPresentNotification(info)
        completionHandler([.alert, .sound])
    }

    public func didReceive(_ info: SPPushNotification, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notificationProcessorDelegate?.handleNotification(info)
        completionHandler()
    }
}

// MARK: - NotificationServiceCapable
extension TwinpushHandler: NotificationServiceCapable {
    public func start() {
        self.setup(deviceId: self.getDeviceId())
    }
    
    public func setProcessorDelegate(_ delegate: NotificationProcessorProtocol) {
        self.notificationProcessorDelegate = delegate
    }

    public var serviceIdentifier: String {
        return ServiceIdentifier.twinpush
    }

    public func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        self.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {}
}

extension TwinpushHandler: TwinpushHandlerProtocol {
    public func getDeviceToken() -> Data? {
        return self.deviceToken
    }
    
    public func handleOTP() {
        guard let lastPush = self.lastPush, let otpHandler = self.otpHandler else { return }
        otpHandler.handleOTPCode(lastPush.otpCode, date: lastPush.date)
        self.lastPush = nil
    }
    
    public func registerOtpHandler(handler: OtpNotificationHandler) {
        self.otpHandler = handler
        self.handleOTP()
    }
    
    public func unregisterOtpHandler() {
        self.otpHandler = nil
    }
    
    public func removeOtpFromUserPref() {
        Scenario(useCase: self.removeOtpPushNotificationsUseCase).execute(on: DispatchQueue.main)
    }
    
    public func didRegisterForRemoteNotifications(deviceToken: Data) {
        self.deviceToken = deviceToken
        self.registerTwinpushAndOTPPush()
        saveOtpPushToken(token: deviceToken)
        self.updateTokenPushSK()
        self.dependenciesResolver.resolve(for: PushNotificationPermissionsManagerProtocol.self).callCompletionRegisterDeviceAndClean()
//        TODO: Esta funcion se debe cambiar debido a que ya tenemos client status cunado este el modulo de autorizaciones
        self.updateToken(deviceToken: deviceToken)
    }
    
    public func registerOtpPushAndSaveToken(deviceId: String) {
        guard let deviceToken = self.deviceToken else { return }
        self.setup(deviceId: deviceId)
        saveOtpPushToken(token: deviceToken)
        saveDeviceId(deviceId: deviceId)
    }
    
    public func updateToken(completion: @escaping ((_ isNew: Bool, _ returnCode: ReturnCodeOTPPush?) -> Void)) {
        isWaitingToUpdateToken = true
        if let deviceToken = self.deviceToken {
            self.completionUpdateToken = completion
            self.updateToken(deviceToken: deviceToken)
        } else {
            completion(false, nil)
        }
    }
}

private extension TwinpushHandler {
    func updateToken(deviceToken: Data) {
        guard isWaitingToUpdateToken else { return }
        isWaitingToUpdateToken = false
//        TODO: Aqui se tendria que llamar a GetClientStatus cuando este el modulo de autorizaciones
        let useCase = ValidateOTPPushDeviceUseCase(dependenciesResolver: self.dependenciesResolver)
        
        Scenario(useCase: useCase, input: ValidateOTPPushDeviceUseCaseInput(deviceToken: deviceToken))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let returnCode = response.returnCode else {
                    self?.completionUpdateToken?(false, nil)
                    return
                }
                switch returnCode {
                case .rightRegisteredDevice:
                    self?.completionUpdateToken?(false, response.returnCode)
                case .anotherRegisteredDevice:
                    self?.completionUpdateToken?(true, response.returnCode)
                case .notRegisteredDevice:
                    self?.completionUpdateToken?(true, response.returnCode)
                }
            }
            .onError { [weak self] _ in
                self?.completionUpdateToken?(false, nil)
            }
    }
    
    func registerTwinpushAndOTPPush() {
        guard let deviceToken = self.deviceToken else { return }
        let useCase = GetLocalPushTokenUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard response.tokenPush != nil else { return }
                self?.setup(deviceId: nil)
                self?.registerOtpPushToken(newToken: deviceToken, completion: { [weak self] isSuccess, error in
                    if isSuccess {
                        self?.trackEvent(.ok)
                    } else {
                        self?.handleRegisterOtpPushTokenError(error)
                    }
                })
            }
    }
    
    func updateTokenPushSK() {
        guard let modifier = dependenciesResolver.resolve(forOptionalType: SantanderKeyUpdateTokenModifierProtocol.self) else {
            return
        }
        modifier.updateToken { [weak self] result in
            if result {
                guard let self = self else { return }
                self.trackEvent(.ok)
            }
        }
    }
    
    func handleRegisterOtpPushTokenError(_ error: GenericUseCaseErrorOutput?) {
        var parameters: [String: String] = [:]
        if let errorDesc = error?.getErrorDesc() {
            parameters[TrackerDimensions.descError] = errorDesc
        }
        if let errorCode = error?.errorCode {
            parameters[TrackerDimensions.codError] = errorCode
        }
        self.trackEvent(.error, parameters: parameters)
    }
}

extension TwinpushHandler: RegisteringOtpPushHandler {}
extension TwinpushHandler: AutomaticScreenActionTrackable {
    public var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    public var trackerPage: OtpPushPage {
        return OtpPushPage()
    }
}
