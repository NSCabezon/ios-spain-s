//
//  UnrememberedLoginPresenter.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation
import CoreFoundationLib
import LoginCommon

protocol UnrememberedLoginPresenterProtocol {
    var view: UnrememberedLoginViewProtocol? { get set }
    var loginManager: LoginManagerDelegate? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    func didShakeWasOccurred()
    func didSelectChooseEnvironment()
    func recoverUserPassword()
    func login(identification: String, magic: String, type: LoginIdentityDocumentType, remember: Bool)
    func getLoginTypeIdentifier() -> String
}

final class UnrememberedLoginPresenter {
    weak var view: UnrememberedLoginViewProtocol?
    weak var loginManager: LoginManagerDelegate?
    let dependenciesResolver: DependenciesResolver
    private var identityDocumentType: LoginIdentityDocumentType = .nif
    private var publicFilesEnvironment: PublicFilesEnvironmentEntity?
    private var urlForgotPassword: String?
    private var shouldRememberUser = false
    private var isCanceled = false
    
    var coordinatorDelegate: LoginCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: LoginCoordinatorDelegate.self)
    }
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().loginUnremembered
    }
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var setTouchIdLoginDataUseCase: SetTouchIdLoginDataUseCase {
        return self.dependenciesResolver.resolve(for: SetTouchIdLoginDataUseCase.self)
    }
    private var deepLinkManager: DeepLinkManagerProtocol {
        return self.dependenciesResolver.resolve(for: DeepLinkManagerProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension UnrememberedLoginPresenter: UnrememberedLoginPresenterProtocol {

    func viewDidLoad() {
        self.loginManager?.setPullOfferLocations(locations)
        self.loginManager?.loadData()
        self.loginManager?.loginReadyForExecuteNotification()
        self.removeExtraPersistedInfo()
        self.trackScreen()
        self.loginManager?.registerUniversalHandler(self)
    }
    
    func viewWillAppear() {
        self.loginManager?.registerAsOtpPushHandler(handler: self)
        self.loginManager?.getCurrentEnvironments()
    }
    
    func viewWillDisappear() {
        self.loginManager?.unRegisterAsOtpPushHandler()
        self.loginManager?.loginWillDisappear()
    }

    func viewDidAppear() {
        self.loginManager?.executeUniversalLink()
    }
    
    func login(identification: String, magic: String, type: LoginIdentityDocumentType, remember: Bool) {
        var identification = (type == .nie) ? self.addZeros(identification) : identification
        self.isCanceled = false
        self.shouldRememberUser = remember
        self.identityDocumentType = type
        self.loginManager?.loginStart()
        self.loginManager?.setLastPasswordLenght(magic.count)
        HapticTrigger.loginSuccess()
        self.trackEvent(.internalLogin, parameters: self.getLocalParameters())
        self.view?.showLoadingWithInfo(completion: {[weak self] in
            self?.doLogin(with: .notPersisted(
                identification: identification,
                magic: magic,
                type: type,
                remember: remember)
            )
        })
    }
    
    func doLogin(with type: LoginType) {
        if self.isCanceled {
            self.loginManager?.resetLoginState()
            self.handleUserCanceled()
        } else {
            self.loginManager?.doLogin(type: type)
        }
    }
    
    private func addZeros(_ text: String) -> String {
        let necesary0s = 9 - text.count
        guard necesary0s > 0 else { return text }
        var textCpy = text
        (0..<necesary0s).forEach { _ in textCpy = "0" + textCpy }
        return textCpy
    }
    
    func didShakeWasOccurred() {
        self.loginManager?.loginCancel()
    }
    
    func didSelectChooseEnvironment() {
        self.coordinatorDelegate.goToEnvironmentsSelector { [weak self] in
            self?.loginManager?.chooseEnvironment()
        }
    }
    
    func recoverUserPassword() {
        guard let url = self.urlForgotPassword else {
            self.view?.showToast(description: "No hay URL configurada para este entorno")
            return
        }
        self.coordinatorDelegate.goToUrl(urlString: url)
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }

    func getLoginTypeIdentifier() -> String {
        switch identityDocumentType {
        case .nif:
            return "login_select_NIF"
        case .nie:
            return "login_select_NIE"
        case .cif:
            return "login_select_CIF"
        case .passport:
            return "login_select_passport"
        case .user:
            return "login_select_user"
        }
    }
}

extension UnrememberedLoginPresenter: LoginPresenterLayerProtocol {
    func cancel() {
        self.isCanceled = true
    }
    
    func handle(event: LoginProcessLayerEvent) {
        switch event {
        case .loginSuccess:
            self.view?.resetForm()
        case .fail(let error, let errorType):
            self.handleLoginError(error, errorType: errorType)
        case .userCanceled:
            self.handleUserCanceled()
        case .netWorkUnavailable:
            self.handleNetworUnavailable()
        default:
            break
        }
    }
    
    func willStartSession() {
        self.coordinatorDelegate.goToFakePrivate(isPb: false, name: "")
        self.view?.showLoadingPlaceHolders()
    }
    
    func loadPullOffersSuccess() {
        self.coordinatorDelegate.reloadSideMenu()
    }
    
    func didLoadCandidatePullOffers(_ offers: [PullOfferLocation: OfferEntity]) {
        let location = offers.location(key: UnrememberedLoginPullOffers.publicTutorial)
        guard let offer = location?.offer else { return }
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didLoadEnvironment(_ environment: EnvironmentEntity, publicFilesEnvironment: PublicFilesEnvironmentEntity) {
        self.urlForgotPassword = environment.urlForgotPassword
        self.publicFilesEnvironment = publicFilesEnvironment
        let wsViewModel = EnvironmentViewModel(title: environment.name, url: environment.urlBase)
        let publicFilesViewModel = EnvironmentViewModel(title: publicFilesEnvironment.name, url: publicFilesEnvironment.urlBase)
        self.view?.updateEnvironmentsText([wsViewModel, publicFilesViewModel])
        self.updateEnvironment(environment)
    }
}

private extension UnrememberedLoginPresenter {
    func updateEnvironment(_ environment: EnvironmentEntity) {
        Scenario(
            useCase: UpdateEnvironmentUseCase(dependenciesResolver: self.dependenciesResolver),
            input: UpdateEnvironmentUseCaseInput(environment: environment)
        ).execute(on: self.dependenciesResolver.resolve())
    }
    
    func handleLoginError(_ error: LocalizedStylableText, errorType: LoginProcessLayerEvent.ErrorType) {
        self.view?.resetPassword()
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
    
    func removeExtraPersistedInfo() {
        let input = SetTouchIdLoginDataInput(deviceMagicPhrase: nil, touchIDLoginEnabled: nil)
        UseCaseWrapper(
            with: self.setTouchIdLoginDataUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler)
        self.loginManager?.removeOtpFromUserPref()
        self.loginManager?.removeScheduledNotifications(forType: .otp)
    }
    
    func getLocalParameters() -> [TrackerDimension: String] {
        var parameters: [TrackerDimension: String] = [:]
        let rememberUser = self.shouldRememberUser ? "true" : "false"
        parameters[TrackerDimension.rememberUser] = rememberUser
        parameters[TrackerDimension.rememberUser] = "clave"
        parameters[TrackerDimension.loginDocumentType] = self.identityDocumentType.metricsValue
        guard let trackerId = self.deepLinkManager.getScheduledDeepLinkTracker() else {
            return parameters
        }
        parameters[TrackerDimension.deeplinkLogin] = trackerId
        return parameters
    }
}

extension UnrememberedLoginPresenter: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        self.loginManager?.removeScheduledNotifications(forType: .otp)
    }
}

extension UnrememberedLoginPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: UnrememberedLoginPage {
        return UnrememberedLoginPage()
    }
}

extension UnrememberedLoginPresenter: LoginSessionHandlerCapable {
    func handleUserCanceled() {
        self.coordinatorDelegate.backToLogin()
        self.view?.resetForm()
        self.view?.dismissLoading()
    }
    
    func handleLoadSessionError(error: LoadSessionError) {
        self.view?.dismissLoading(completion: { [weak self] in
            guard let self = self else { return }
            let errorMessage = LoginSessionErrorMessage().localizedError(error)
            self.coordinatorDelegate.backToLogin()
            self.view?.showLoginError(errorMessage)
            var parameters = self.getLocalParameters()
            parameters[TrackerDimension.codError] = ""
            parameters[TrackerDimension.descError] = errorMessage.text
            self.trackEvent(.error, parameters: parameters)
        })
    }
}

extension UnrememberedLoginPresenter: TrackMetricsLocationCapable {
    func trackUserLocation(parameters: [TrackerDimension: String]) {
        self.trackEvent(.userLocation, parameters: parameters)
    }
}

extension UnrememberedLoginPresenter: HandleLoadSessionDataSuccessCapable {
    var loginView: LoginViewCapable? {
        return self.view
    }
}

extension UnrememberedLoginPresenter: HandleScaBloquedCapable {}
extension UnrememberedLoginPresenter: HandleScaOtpCapable {}
extension UnrememberedLoginPresenter: UpdateLoadingMessageCapable {}
extension UnrememberedLoginPresenter: HandleNetworkingErrorCapable {}
extension UnrememberedLoginPresenter: UniversalLauncherPresentationHandler {}
