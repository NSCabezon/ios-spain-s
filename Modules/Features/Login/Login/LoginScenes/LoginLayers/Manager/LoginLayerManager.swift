//
//  LoginLayerManager.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation
import CoreFoundationLib
import CorePushNotificationsService
import ESCommons

protocol LoginManagerDelegate: class {
    func loadData()
    func loginReadyForExecuteNotification()
    func doLogin(type: LoginType)
    func loginStart()
    func loginWillDisappear()
    func setLastPasswordLenght(_ lenght: Int)
    func loginCancel()
    func resetLoginState()
    func removeOtpFromUserPref()
    func removeScheduledNotifications(forType type: PushExecutableType)
    func registerAsOtpPushHandler(handler: OtpNotificationHandler)
    func unRegisterAsOtpPushHandler()
    func setPullOfferLocations(_ locations: [PullOfferLocation])
    func chooseEnvironment()
    func getCurrentEnvironments()
    func getSessionCloseReason() -> SessionFinishedReason
    func isSessionExpired() -> Bool
    func closeReasonLogout()
    func executeUniversalLink()
    func registerUniversalHandler(_ presenting: UniversalLauncherPresentationHandler)
}

protocol LoginPresenterLayerProtocol: Cancelable {
    func handle(event: LoginProcessLayerEvent)
    func handle(event: SessionManagerProcessEvent)
    func willStartSession()
    func loadPullOffersSuccess()
    func didLoadCandidatePullOffers(_ offers: [PullOfferLocation: OfferEntity])
    func didLoadEnvironment(_ environment: EnvironmentEntity, publicFilesEnvironment: PublicFilesEnvironmentEntity)
    func onSuccess()
    func onScaBloqued()
    func onScaOtp(firstTime: Bool, userName: String)
}

final class LoginLayerManager {
    private let dependenciesResolver: DependenciesResolver
    
    private var publicFilesManager: PublicFilesManagerProtocol {
        return self.dependenciesResolver.resolve(for: PublicFilesManagerProtocol.self)
    }
    
    private var pushNotificationExecutor: PushNotificationsExecutorProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: PushNotificationsExecutorProtocol.self)
    }
    
    private var pushNotificationsUserInfo: PushNotificationsUserInfo? {
        return self.dependenciesResolver.resolve(forOptionalType: PushNotificationsUserInfo.self)
    }
    
    private var pushNotificationsManager: InboxMessagesManager {
        return self.dependenciesResolver.resolve()
    }

    private var universalLinkManager: UniversalLinkManagerProtocol {
        return self.dependenciesResolver.resolve(for: UniversalLinkManagerProtocol.self)
    }

    private var otpPushManager: OtpPushManagerProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }
    
    private lazy var loginProcessLayer: LoginProcessLayerProtocol = {
        let processLayer = self.dependenciesResolver.resolve(for: LoginProcessLayerProtocol.self)
        processLayer.setDelegate(self)
        return processLayer
    }()
    
    private lazy var loginSessionLayer: LoginSessionLayer = {
        let sessionLayer = self.dependenciesResolver.resolve(for: LoginSessionLayer.self)
        sessionLayer.setDelegate(self)
        return sessionLayer
    }()
    
    private lazy var loginPullOfferLayer: LoginPullOfferLayer = {
        let pullOfferLayer = self.dependenciesResolver.resolve(for: LoginPullOfferLayer.self)
        pullOfferLayer.setDelegate(self)
        return pullOfferLayer
    }()
    
    private lazy var loginEnvironmentLayer: LoginEnvironmentLayer = {
        let environmentLayer = self.dependenciesResolver.resolve(for: LoginEnvironmentLayer.self)
        environmentLayer.setDelegate(self)
        return environmentLayer
    }()
    
    private lazy var loginPresenterLayer: LoginPresenterLayerProtocol = {
        return self.dependenciesResolver.resolve(for: LoginPresenterLayerProtocol.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    deinit {
        self.publicFilesManager.remove(subscriptor: LoginLayerManager.self)
    }
}

extension LoginLayerManager: LoginManagerDelegate {
    func getSessionCloseReason() -> SessionFinishedReason {
        guard let closeReason = self.loginSessionLayer.getCloseReason() else {
            return .unknown
        }
        return closeReason
    }
    
    func loadData() {
        if self.loginSessionLayer.getCloseReason() != .unknown {
            self.publicFilesManager.loadPublicFiles(withStrategy: PublicFilesStrategyType.initialLoad, timeout: 0)
        }
        self.publicFilesManager.add(subscriptor: LoginLayerManager.self) { [weak self] in
            self?.publicFilesLoadingDidFinish()
        }
    }
    
    func loginWillDisappear() {
        self.publicFilesManager.remove(subscriptor: LoginLayerManager.self)
    }
    
    func loginReadyForExecuteNotification() {
        self.pushNotificationExecutor?.executeNotificationReceived()
    }
    
    func doLogin(type: LoginType) {
        self.loginProcessLayer.doLogin(with: type)
        self.loginSessionLayer.setLoginState(.login)
        self.setSessionLayerLoginType(type: type)
    }

    func setSessionLayerLoginType(type: LoginType) {
        switch type {
        case .notPersisted(let identification, let magic, let type, let remember):
            self.loginSessionLayer.setIsBiometricLogin(false)
        case .persisted(let authLogin):
            switch authLogin {
            case .biometric(let biometricToken, let footprint, let channelFrame, let isPb):
                self.loginSessionLayer.setIsBiometricLogin(true)
            case .magic(let magic):
                self.loginSessionLayer.setIsBiometricLogin(false)
            }
        }
    }
    
    func loginStart() {
        self.loginProcessLayer.restore()
        self.loginSessionLayer.setLoginState(.start)
    }
    
    func resetLoginState() {
        self.loginSessionLayer.setLoginState(.none)
    }
    
    func loginCancel() {
        switch self.loginSessionLayer.getLoginState() {
        case .login:
            self.loginProcessLayer.cancel()
        case .globalPosition:
            self.loginSessionLayer.cancel()
        case .start:
            self.loginPresenterLayer.cancel()
        case .none:
            break
        }
    }
    
    func setLastPasswordLenght(_ lenght: Int) {
        self.loginSessionLayer.setLastPasswordLenght(lenght)
    }
    
    func removeOtpFromUserPref() {
        self.otpPushManager?.removeOtpFromUserPref()
    }
    
    func removeScheduledNotifications(forType type: PushExecutableType) {
        self.pushNotificationExecutor?.removeScheduledNotifications(forType: type)
    }
    
    func registerAsOtpPushHandler(handler: OtpNotificationHandler) {
        self.otpPushManager?.registerOtpHandler(handler: handler)
    }
    
    func unRegisterAsOtpPushHandler() {
        self.otpPushManager?.unregisterOtpHandler()
    }
    
    func setPullOfferLocations(_ locations: [PullOfferLocation]) {
        self.loginPullOfferLayer.setPullOfferLocations(locations)
    }
    
    func chooseEnvironment() {
        self.publicFilesManager.loadPublicFiles(withStrategy: .reload, timeout: 5)
        self.loginEnvironmentLayer.getCurrentEnvironments()
    }
    
    func getCurrentEnvironments() {
        self.loginEnvironmentLayer.getCurrentEnvironments()
    }
    
    func isSessionExpired() -> Bool {
        return self.loginSessionLayer.isSessionExpired()
    }
    
    func closeReasonLogout() {
        self.loginSessionLayer.changeCloseReason(.logOut)
    }

    func registerUniversalHandler(_ presenting: UniversalLauncherPresentationHandler) {
        universalLinkManager.registerPresenting(presenting)
    }
    
    func executeUniversalLink() {
        universalLinkManager.launchWithPresentingIfNeeded()
    }
}

extension LoginLayerManager: LoginProcessLayerEventDelegate {
    func handle(event: LoginProcessLayerEvent) {
        switch event {
        case .willLogin:
            self.publicFilesManager.cancelPublicFilesLoad(withStrategy: .initialLoad)
        default:
            break
        }
        self.loginSessionLayer.handle(event: event)
        self.loginPresenterLayer.handle(event: event)
    }
}

extension LoginLayerManager: LoginSessionLayerEventDelegate {
    func onSuccess() {
        self.loginPresenterLayer.onSuccess()
    }
    
    func onBloqued() {
        self.loginPresenterLayer.onScaBloqued()
    }
    
    func onOtp(firsTime: Bool, userName: String?) {
        self.loginPresenterLayer.onScaOtp(firstTime: firsTime, userName: userName ?? "")
    }
    
    func willOpenSession(completion: @escaping () -> Void) {
        self.loginPresenterLayer.willStartSession()
        self.publicFilesManager.add(subscriptor: LoginLayerManager.self) {
            completion()
        }
    }
    
    func handle(event: SessionManagerProcessEvent) {
        self.loginPresenterLayer.handle(event: event)
        switch event {
        case .loadDataSuccess:
            self.pushNotificationsUserInfo?.updateUserInfo()
            self.pushNotificationsManager.markAllAsRead()
        default:
            break
        }
    }
}

extension LoginLayerManager: LoginPullOfferLayerDelegate {
    func publicFilesLoadingDidFinish() {
        self.loginPullOfferLayer.loadPullOffers()
    }
    
    func loadPullOffersSuccess() {
        guard self.loginSessionLayer.getLoginState() == .none else { return }
        self.loginPresenterLayer.loadPullOffersSuccess()
    }
    
    func didLoadCandidatePullOffers(_ offers: [PullOfferLocation: OfferEntity]) {
        guard self.loginSessionLayer.getLoginState() == .none else { return }
        self.loginPresenterLayer.didLoadCandidatePullOffers(offers)
    }
}

extension LoginLayerManager: LoginEnvironmentLayerDelegate {
    func didLoadEnvironment(_ environment: EnvironmentEntity,
                            publicFilesEnvironment: PublicFilesEnvironmentEntity) {
        self.loginPresenterLayer.didLoadEnvironment(environment, publicFilesEnvironment: publicFilesEnvironment)
    }
}
