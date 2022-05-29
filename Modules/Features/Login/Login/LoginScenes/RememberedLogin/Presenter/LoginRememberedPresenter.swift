//
//  LoginRememberedPresenter.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import CoreFoundationLib
import Foundation
import ESCommons
import LoginCommon
import Ecommerce

protocol LoginRememberedPresenterProtocol {
    var view: LoginRememberedViewProtocol? { get set }
    var loginManager: LoginManagerDelegate? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    func didShakeWasOccurred()
    func didSelectChooseEnvironment()
    func didSelectMenu()
    func loginWithMagic(_ magic: String)
    func changeUser()
    func quickBalance()
    func onAlertDismissed()
    func performBiometryAction()
    func recoverUserPassword()
    func didTapSantanderKey()
    func updateEcommerceEnabledState()
}

final class LoginRememberedPresenter {
    let dependenciesResolver: DependenciesResolver
    weak var view: LoginRememberedViewProtocol?
    weak var loginManager: LoginManagerDelegate?
    private var persistedUser: PersistedUserEntity?
    private var lastOtpViewModel: OTPCodeViewModel?
    private let maxSecondsForExpiringOtp: Int = 5 * 60
    private var urlForgotPassword: String?
    private var isBiometric = false
    private var isCanceled = false
    var doBiometryAction: (() -> Void)?
    var isLoginWithTouchIdEnabled: Bool = false
    var fingerprintAcceptedByUser: Bool = false
    var cancelAutomaticEvaluation: Bool = false
    private var ecommerceEnable: Bool?
    
    var coordinatorDelegate: LoginCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: LoginCoordinatorDelegate.self)
    }
    var coordinatorProtocol: LoginRememberedCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: LoginRememberedCoordinatorProtocol.self)
    }
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().loginReembered
    }
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    private var compilation: CompilationProtocol {
        return self.dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    private var getOtpPushNotificationUseCase: GetOtpPushNotificationUseCase {
        return self.dependenciesResolver.resolve(for: GetOtpPushNotificationUseCase.self)
    }
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var loadRememberedLoginDataUseCase: LoadRememberedLoginDataUseCase {
        return self.dependenciesResolver.resolve(for: LoadRememberedLoginDataUseCase.self)
    }
    private var removePersistedUserUseCase: RemovePersistedUserUseCase {
        return self.dependenciesResolver.resolve(for: RemovePersistedUserUseCase.self)
    }
    private var setWidgetAccessUseCase: SetWidgetAccessUseCase {
        return self.dependenciesResolver.resolve(for: SetWidgetAccessUseCase.self)
    }
    private var isEcommerceEnabledUseCase: IsEcommerceEnabledUseCase {
        return self.dependenciesResolver.resolve(for: IsEcommerceEnabledUseCase.self)
    }
    private var paramTracker: LoginRememberParamTracker {
        return self.dependenciesResolver.resolve(for: LoginRememberParamTracker.self)
    }
    private var appEventsNotifier: AppEventsNotifierProtocol {
        self.dependenciesResolver.resolve(for: AppEventsNotifierProtocol.self)
    }
    private var siriIntents: SiriIntentsManagerProtocol {
        return self.dependenciesResolver.resolve(for: SiriIntentsManagerProtocol.self)
    }
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension LoginRememberedPresenter: LoginRememberedPresenterProtocol {
    func viewDidLoad() {
        self.loadLoginType()
        self.loginManager?.setPullOfferLocations(locations)
        self.loginManager?.loadData()
        self.getPersistedUser()
        self.trackScreen()
        self.updateEcommerceEnabledState()
        self.loginManager?.registerUniversalHandler(self)
    }
    
    func viewWillAppear() {
        self.loginManager?.registerAsOtpPushHandler(handler: self)
        self.loginManager?.getCurrentEnvironments()
        self.appEventsNotifier.add(didBecomeActiveSubscriptor: self)
        self.doBiometryAction?()
        self.getLastOtp()
        self.siriIntents.setDelegate(self)
    }
    
    func viewWillDisappear() {
        self.loginManager?.unRegisterAsOtpPushHandler()
        self.appEventsNotifier.remove(didBecomeActiveSubscriptor: self)
        self.loginManager?.loginWillDisappear()
    }
    
    func viewDidAppear() {
        self.handleLogoutReasons()
        self.automaticBiometryLogin {
            self.loginManager?.loginReadyForExecuteNotification()
        }
        self.loginManager?.executeUniversalLink()
    }
    
    func didShakeWasOccurred() {
        self.loginManager?.loginCancel()
    }
    
    func didSelectChooseEnvironment() {
        self.coordinatorDelegate.goToEnvironmentsSelector { [weak self] in
            self?.loginManager?.chooseEnvironment()
        }
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func changeUser() {
        self.removePersistedUser(completion: { [weak self] in
            self?.disableWidget()
            self?.coordinatorDelegate.goToPublic(shouldGoToRememberedLogin: false)
        })
    }
    
    func quickBalance() {
        self.coordinatorDelegate.goToQuickBalance()
    }
    
    func onAlertDismissed() {
        self.loginManager?.removeOtpFromUserPref()
        self.lastOtpViewModel = nil
    }
    
    func recoverUserPassword() {
        guard let url = self.urlForgotPassword else {
            self.view?.showToast(description: "No hay URL configurada para este entorno")
            return
        }
        self.coordinatorDelegate.goToUrl(urlString: url)
    }
    
    func loginWithMagic(_ magic: String) {
        self.loginManager?.setLastPasswordLenght(magic.count)
        let loginParam = LoginParamViewModel(
            isBiometric: false,
            biometricToken: nil,
            footprint: nil,
            isPb: nil,
            password: magic
        )
        self.login(with: loginParam)
    }
    
    func didTapSantanderKey() {
        coordinatorProtocol.showEcommerce()
        trackEvent(.ecommerceButton, parameters: [:])
    }
    
    func updateEcommerceEnabledState() {
        if let ecommerceEnable = self.ecommerceEnable {
            self.view?.displayEcommerceView(ecommerceEnable)
        } else {
            UseCaseWrapper(
                with: self.isEcommerceEnabledUseCase,
                useCaseHandler: useCaseHandler,
                onSuccess: { [weak self] response in
                    self?.ecommerceEnable = response.isEnabled
                    self?.view?.displayEcommerceView(response.isEnabled)
                })
        }
    }
}

extension LoginRememberedPresenter: LoginPresenterLayerProtocol {
    
    func cancel() {
        self.isCanceled = true 
    }
    
    func handle(event: LoginProcessLayerEvent) {
        switch event {
        case .loginSuccess:
            self.view?.clearPassword()
            self.view?.enableUserInteraction()
        case .userCanceled:
            self.handleUserCanceled()
            self.view?.clearPassword()
            self.view?.enableUserInteraction()
        case .failedBiometric:
            self.failedBiometric()
            self.view?.clearPassword()
            self.view?.enableUserInteraction()
        case .fail(let error, let errorType):
            self.handleLoginError(error, errorType: errorType)
            self.view?.didTapOnAccessPassword()
            self.view?.enableUserInteraction()
            self.handleBiometryError(errorType)
        case .netWorkUnavailable:
            self.handleNetworUnavailable()
            self.view?.didTapOnAccessPassword()
            self.view?.enableUserInteraction()
        default:
            break
        }
        self.safetyCurtainSafeguardEventDidFinish()
    }
    
    func willStartSession() {
        self.coordinatorDelegate.goToFakePrivate(isPb: false, name: "")
        self.view?.showLoadingPlaceHolders()
    }
    
    func loadPullOffersSuccess() {
        self.coordinatorDelegate.reloadSideMenu()
    }
    
    func didLoadCandidatePullOffers(_ offers: [PullOfferLocation: OfferEntity]) {
        let location = offers.location(key: LoginRememberedPullOffers.publicTutorialRec)
        guard let offer = location?.offer else { return }
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didLoadEnvironment(_ environment: EnvironmentEntity, publicFilesEnvironment: PublicFilesEnvironmentEntity) {
        self.urlForgotPassword = environment.urlForgotPassword
        let wsViewModel = EnvironmentViewModel(title: environment.name, url: environment.urlBase)
        let publicFilesViewModel = EnvironmentViewModel(title: publicFilesEnvironment.name, url: publicFilesEnvironment.urlBase)
        self.view?.updateEnvironmentsText([wsViewModel, publicFilesViewModel])
        self.updateEnvironment(environment)
    }
}

extension LoginRememberedPresenter: SiriIntentsPresentationDelegate {
    var letPerformIntent: Bool {
        self.cancelAutomaticEvaluation = true
        return true
    }
    
    func intentDidPerform() {}
}

extension LoginRememberedPresenter: AppEventDidBecomeActiveSuscriptor {
    func applicationDidBecomeActive() {
        self.getLastOtp()
    }
}

extension LoginRememberedPresenter: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let date = date else { return }
        let isANewOtp = self.isNewOtp(newDate: date, remainingTime: maxSecondsForExpiringOtp)
        guard isANewOtp, let code = code else { return }
        let viewModel = self.getOTPCodeViewModel(withCode: code, andDate: date)
        guard let otpViewModel = viewModel, otpViewModel.time.remainingTime > 0 else { return }
        self.lastOtpViewModel = otpViewModel
        self.view?.showOTPCode(otpViewModel)
    }
    
    func isNewOtp(newDate: Date, remainingTime: Int) -> Bool {
        guard let lastOtpViewModel = self.lastOtpViewModel else { return true }
        return lastOtpViewModel.date < newDate
    }
    
    func getOTPCodeViewModel(withCode code: String, andDate date: Date) -> OTPCodeViewModel? {
        return OTPCodeViewModel(
            code: code,
            notificationDate: date,
            shouldFinishIn: self.maxSecondsForExpiringOtp,
            actualDate: self.timeManager.getCurrentLocaleDate(inputDate: Date()))
    }
    
    func getLastOtp() {
        MainThreadUseCaseWrapper(
            with: self.getOtpPushNotificationUseCase,
            onSuccess: { [weak self] result in
                switch result {
                case .expiredCode:
                    self?.view?.hideOtpCode()
                case .code(let code, let date, let remainingTime):
                    self?.showLastOtp(code: code, date: date, remainingTime: remainingTime)
                case .noCode:
                    break
                }
            })
    }
    
    func showLastOtp(code: String, date: Date, remainingTime: Int) {
        guard self.isNewOtp(newDate: date, remainingTime: remainingTime) else {
            self.view?.expandOtpCode()
            return
        }
        let otpViewModel = OTPCodeViewModel(
            code: code,
            date: date,
            totalTime: self.maxSecondsForExpiringOtp,
            remainingTime: remainingTime)
        self.lastOtpViewModel = otpViewModel
        self.view?.showOTPCode(otpViewModel)
    }
}

extension LoginRememberedPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: LoginRememberedPage {
        return LoginRememberedPage()
    }
}

extension LoginRememberedPresenter: SafetyCurtainDoorman {}

extension LoginRememberedPresenter: BiometryLoginCapable {
    var biometryLoginView: BiometryLoginView? {
        return self.view
    }
    
    func isPbUser() -> Bool {
        return self.persistedUser?.isPb == true
    }
    
    func doBiometryLogin(with params: LoginParamViewModel) {
        self.login(with: params)
    }
    
    func getSessionCloseReason() -> SessionFinishedReason? {
        return self.loginManager?.getSessionCloseReason()
    }
    
    func isSessionExpired() -> Bool {
        return self.loginManager?.isSessionExpired() == true
    }
    
    func failWithBiometryError(_ error: String) {
        var parameters = self.paramTracker.getDeepLinkParameters()
        parameters[TrackerDimension.codError] = ""
        parameters[TrackerDimension.descError] = error
        self.trackEvent(.error, parameters: parameters)
    }
    
    func willPromptBiometryAlert() {
        self.safetyCurtainSafeguardEventWillBegin()
    }
    
    func biometryAlertDidFinish() {
        self.safetyCurtainSafeguardEventDidFinish()
    }
}

extension LoginRememberedPresenter: HandleLoadSessionDataSuccessCapable {
    var loginView: LoginViewCapable? {
        return self.view
    }
}

extension LoginRememberedPresenter: TrackMetricsLocationCapable {
    func trackUserLocation(parameters: [TrackerDimension: String]) {
        self.trackEvent(.userLocation, parameters: parameters)
    }
}

extension LoginRememberedPresenter: LoginSessionHandlerCapable {
    func handleLoadSessionError(error: LoadSessionError) {
        self.view?.dismissLoading(completion: { [weak self] in
            guard let self = self else { return }
            let errorMessage = LoginSessionErrorMessage().localizedError(error)
            self.coordinatorDelegate.backToLogin()
            self.view?.showLoginError(errorMessage)
            self.view?.enableUserInteraction()
            var parameters = self.getParameters()
            parameters[TrackerDimension.codError] = ""
            parameters[TrackerDimension.descError] = errorMessage.text
            self.trackEvent(.error, parameters: parameters)
        })
    }
    
    func handleUserCanceled() {
        self.coordinatorDelegate.backToLogin()
        self.view?.didAccessWithWrongPassword()
        self.view?.dismissLoading()
    }
}

private extension LoginRememberedPresenter {
    func updateEnvironment(_ environment: EnvironmentEntity) {
        Scenario(
            useCase: UpdateEnvironmentUseCase(dependenciesResolver: self.dependenciesResolver),
            input: UpdateEnvironmentUseCaseInput(environment: environment)
        ).execute(on: self.dependenciesResolver.resolve())
    }
    
    func getPersistedUser() {
        MainThreadUseCaseWrapper(with: self.loadRememberedLoginDataUseCase,
                                 onSuccess: { [weak self] result in
                                    guard let self = self else { return }
                                    let user = result.persistedUser
                                    self.persistedUserObtained(user)
                                    self.setSantanderLogo(semanticSegmentType: result.type)
                                    self.setLoginBackground(result.backgroundType)
                                    self.setGreeting(result.alias)
                                 }, onError: { [weak self] _ in
                                    guard let self = self else { return }
                                    self.persistedUserObtained(nil)
                                    self.setLoginBackground(nil)
                                    self.setGreeting(nil)
                                 })
    }
    
    func persistedUserObtained(_ user: PersistedUserEntity?) {
        self.persistedUser = user
        guard let user = self.persistedUser, user.isMagicAllowed else { return }
        self.autocompleteWithDebugPassword()
    }
    
    func autocompleteWithDebugPassword() {
        guard let demoLogin = self.compilation.debugLoginSetup else { return }
        self.view?.autocompletePasswordWith(demoLogin.defaultMagic)
    }
    
    func setSantanderLogo(semanticSegmentType: SemanticSegmentTypeEntity) {
        let viewModel = SantanderLogoViewModel(semanticSegmentType: semanticSegmentType)
        self.view?.setSantanderLogoViewModel(viewModel)
    }
    
    func setLoginBackground(_ backgroundType: RememberedLoginBackgroundType?) {
        guard let backgroundType = backgroundType else {
            self.view?.setDefaultBackgroundImage()
            return
        }
        let viewModel = RememberedLoginBackgroundViewModel(backgroundType: backgroundType)
        self.view?.setBackgroundViewModel(viewModel)
    }
    
    func setGreeting(_ alias: String?) {
        let greeting = (alias?.isEmpty != false) ? self.persistedUser?.name?.camelCasedString : alias
        self.view?.setGreeting(greeting)
    }
    
    func login(with params: LoginParamViewModel) {
        guard self.persistedUser != nil else { return }
        self.isBiometric = params.isBiometric
        self.view?.disableUserInteraction()
        HapticTrigger.loginSuccess()
        self.trackEvent(.internalLogin, parameters: self.getParameters())
        self.isCanceled = false
        self.loginManager?.loginStart()
        self.view?.showLoadingWithInfo(completion: { [weak self] in
            guard self?.isCanceled == false else {
                self?.view?.enableUserInteraction()
                self?.handleUserCanceled()
                return
            }
            let auth = params.getAuthLogin(user: self?.persistedUser)
            self?.doLogin(with: auth)
        })
    }
    
    func doLogin(with auth: AuthLogin?) {
        guard let auth = auth else {
            self.view?.dismissLoading()
            self.view?.enableUserInteraction()
            return
        }
        self.loginManager?.doLogin(type: .persisted(auth))
    }
    
    func getParameters() -> [TrackerDimension: String] {
        return self.paramTracker.getParameters(
            user: self.persistedUser,
            isBiometric: self.isBiometric
        )
    }
    
    func handleLoginError(_ error: LocalizedStylableText,
                          errorType: LoginProcessLayerEvent.ErrorType) {
        self.view?.didAccessWithWrongPassword()
        self.view?.dismissLoading(completion: { [weak self] in
            self?.coordinatorDelegate.backToLogin()
            switch errorType {
            case .any:
                self?.view?.showLoginError(error)
            default:
                self?.view?.showLoginErrorInfinite(error)
            }
        })
    }
    
    func removePersistedUser(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.removePersistedUserUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { _ in
                completion()
            }, onError: { _ in
                completion()
            })
        self.coordinatorDelegate.deleteSiriIntents()
    }
    
    func disableWidget() {
        let input = SetWidgetAccessInput(isWidgetEnabled: false)
        UseCaseWrapper(with: self.setWidgetAccessUseCase.setRequestValues(requestValues: input),
                       useCaseHandler: useCaseHandler)
    }
    
    func handleLogoutReasons() {
        switch self.getSessionCloseReason() {
        case .failedGPReload(let reason):
            self.view?.showLoginError(localized(reason ?? "generic_error_internetConnection"))
            self.loginManager?.closeReasonLogout()
        case .timeoutInactivity, .timeoutOutOfApp, .failRenewTokenService, .failRenewTokenException:
            self.view?.showLoginError(localized("login_popup_expiredSession"))
            self.loginManager?.closeReasonLogout()
        case .notAuthorized, .unknown, .logOut, .none:
            break
        }
    }
}

extension LoginRememberedPresenter: HandleScaBloquedCapable {}
extension LoginRememberedPresenter: HandleScaOtpCapable {}
extension LoginRememberedPresenter: UpdateLoadingMessageCapable {}
extension LoginRememberedPresenter: HandleNetworkingErrorCapable {}
extension LoginRememberedPresenter: UniversalLauncherPresentationHandler {}
