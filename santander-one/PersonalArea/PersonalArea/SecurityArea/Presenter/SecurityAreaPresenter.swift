import SANLegacyLibrary
import CoreFoundationLib
import UI

protocol SecurityAreaPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: SecurityAreaViewProtocol? { get set }
    var showIconTitleHeader: Bool { get }
    var tooltipItems: [(text: String, image: String)] { get }
    func viewDidLoad()
    func viewDidAppear()
    func didBecomeActive()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectAction(_ action: SecurityActionType)
    func didSelectSwitchAction(_ action: SecurityActionType, _ isSwitchOn: Bool)
    func didSelectSwitchCustomAction(_ action: CustomAction, _ isSwitchOn: Bool)
    func didSelectVideo(_ viewModel: SecurityVideoViewModel)
    func didSelectSecurityTip(_ viewModel: HelpCenterTipViewModel)
    func securityTipsScrollViewDidEndDecelerating()
}

extension SecurityAreaPresenterProtocol {
    var tooltipItems: [(text: String, image: String)] {
        [(text: "securityTooltip_text_secureDevice", image: "icnPhoneSecure"),
         (text: "securityTooltip_text_alert", image: "icnRing"),
         (text: "securityTooltip_text_fraud", image: "icnFraud"),
         (text: "securityTooltip_text_cardTheft", image: "icnStolenCard"),
         (text: "securityTooltip_text_permissions", image: "icnArrowPhone"),
         (text: "securityTooltip_text_travelMode", image: "icnParachute")]
    }
}

enum SecurityAreaViewState {
    case initialState
    case everythingLoaded
    case shouldLoad
}

final class SecurityAreaPresenter {
    weak var view: SecurityAreaViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var userPref: UserPrefWrapper
    var offers: [PullOfferLocation: OfferEntity] = [:]
    var state: SecurityAreaViewState = .initialState
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.userPref = self.dependenciesResolver.resolve(for: UserPrefWrapper.self)
    }
    
    private lazy var biometryConfigurator: BiometryConfigurator = {
        BiometryConfigurator(dependenciesResolver: dependenciesResolver)
    }()
    private lazy var biometryAction: PersonalAreaBiometryAction = {
        return PersonalAreaBiometryAction(dependenciesResolver: dependenciesResolver)
    }()
    private lazy var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate = {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }()
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().securityArea
    }
    var safeBoxOfferKey: String?
    private lazy var globalSecurityViewContainer: GlobalSecurityViewContainerProtocol = {
        return self.dependenciesResolver.resolve(firstTypeOf: GlobalSecurityViewContainerProtocol.self)
    }()
    var isThirdPartyPermissionsHidden: Bool?
    var isTripModeEnabled: Bool?
    var isOtpPushEnabled: Bool?
    var isPasswordViewEnabled: Bool?
    var isProtectionViewEnabled: Bool?
    var fraudViewModel: PhoneViewModel?
    var cardBlockViewModel: [PhoneViewModel]?
    var alertSecurityViewModel: SecurityViewModel?
    var lastLogonViewModel: LastLogonViewModel?
    var showIconTitleHeader: Bool {
        return self.dependenciesResolver.resolve(forOptionalType: SecurityAreaViewProtocolModifier.self)?.showIconTitleHeader
        ?? true
    }
    var tooltipItems: [(text: String, image: String)] {
        if let modifier = self.dependenciesResolver.resolve(forOptionalType: SecurityAreaViewProtocolModifier.self) {
            return modifier.tooltipItems
        }

        return [(text: "securityTooltip_text_secureDevice", image: "icnPhoneSecure"),
                (text: "securityTooltip_text_alert", image: "icnRing"),
                (text: "securityTooltip_text_fraud", image: "icnFraud"),
                (text: "securityTooltip_text_cardTheft", image: "icnStolenCard"),
                (text: "securityTooltip_text_permissions", image: "icnArrowPhone"),
                (text: "securityTooltip_text_travelMode", image: "icnParachute")]
    }
}

extension SecurityAreaPresenter: SecurityAreaPresenterProtocol {
    func viewDidLoad() {
        self.getGlobaViewInfoData { [weak self] in
            self?.setOfferConfiguration()
            self?.setContainer()
            self?.getSecurityTips()
        }
        self.getIsSearchEnabled()
        self.trackScreen()
    }
    
    func viewDidAppear() {
        guard case .shouldLoad = self.state else { return }
        self.loadPersonalInformation()
    }
    
    func didBecomeActive() {
        self.loadPersonalInformation()
    }
    
    func didSelectVideo(_ viewModel: SecurityVideoViewModel) {
        self.coordinatorDelegate.didSelectOffer(viewModel.offer)
    }
    
    func didSelectSecurityTip(_ viewModel: HelpCenterTipViewModel) {
        self.coordinatorDelegate.didSelectOffer(viewModel.entity.offer)
    }
    
    func securityTipsScrollViewDidEndDecelerating() {
        trackEvent(.swipe, parameters: [:])
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectSearch() {
        self.coordinatorDelegate.didSelectSearch()
    }
    
    func didSelectAction(_ action: SecurityActionType) {
        trackActionEvent(action)
        switch action {
        case .secureDevice:
            self.coordinator.goToSecureDevice()
        case .phone, .email:
            self.executeContactOffer(action)
        case .operativeUser:
            self.goToOperabilityChange()
        case .accountMovement, .noAction:
            break
        case .biometrySystem, .geolocation, .changePassword, .changeSignature, .video:
            self.coordinatorDelegate.didSelectAction(action)
        }
    }
    
    func didSelectSwitchAction(_ action: SecurityActionType, _ isSwitchOn: Bool) {
        switch action {
        case .geolocation:
            let event: SecurityAreaPage.Action = isSwitchOn ? .geolocationOn : .geolocationOff
            trackEvent(event, parameters: [:])
            self.changeLocationPermissions(isSwitchOn)
        case .biometrySystem:
            let event: SecurityAreaPage.Action = isSwitchOn ? .biometricOn : .biometricOff
            trackEvent(event, parameters: [:])
            biometryAction.didSelectBiometry { [weak self] reload in
                if reload { self?.loadPersonalInformation() }
            }
        default:
            self.coordinatorDelegate.didSelectAction(action)
        }
    }
    
    func didSelectSwitchCustomAction(_ action: CustomAction, _ isSwitchOn: Bool) {
        action { [weak self] reload in
            if reload { self?.loadPersonalInformation() }
        }
    }
}

extension SecurityAreaPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: SecurityAreaPage {
        return SecurityAreaPage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension SecurityAreaPresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

// MARK: - Private Methods
private extension SecurityAreaPresenter {
    func setContainer() {
        let containerView = self.globalSecurityViewContainer.createView(data: self, delegate: self)
        self.view?.setContainer(containerView)
    }
    
    func changeLocationPermissions(_ isSwitchOn: Bool) {
        guard isSwitchOn else { self.showNativeLocationPermissions()
            return
        }
        self.showLisboaLocationPermissionsDialog(acceptAction: { [weak self] in
            self?.showNativeLocationPermissions()
        }, cancelAction: { [weak self] in
            self?.loadPersonalInformation()
        })
    }
    
    func loadPersonalInformation(_ completion: (() -> Void)? = nil) {
        self.personalAreaDataManager.loadPersonalAreaPreferences { [weak self] in
            self?.getPersonalInformation { [weak self] personalInformation in
                self?.setPersonalInformation(personalInformation)
                completion?()
            }
        }
    }
    
    func setPersonalInformation (_ personalInformation: PersonalInformationEntity?) {
        self.updateUserPreferenceWithBasicInformation(personalInformation)
        self.setValidatedDeviceState()
    }
    
    func updateUserPreferenceWithBasicInformation(_ personalInformation: PersonalInformationEntity?) {
        self.userPref.personalInfo =
            PersonalInfoWrapper(
                address: personalInformation?.mainAddress,
                kindOfDocument: personalInformation?.documentType?.rawValue,
                document: personalInformation?.documentNumber,
                phone: personalInformation?.phoneNumber,
                smsPhone: personalInformation?.smsPhoneNumber,
                email: personalInformation?.email
            )
    }
    
    func setValidatedDeviceState() {
        self.getValidatedDeviceState { [weak self] validatedDeviceState in
            self?.setSecurityAreaActions(validatedDeviceState)
        }
    }
    
    func setSecurityAreaActions(_ validatedDeviceState: ValidatedDeviceStateEntity) {
        updateBiometryPreferences()
        let videoOffer = self.offers.location(key: SecurityAreaPullOffers.deviceSecurityVideo)?.offer
        if let actionsProvider = dependenciesResolver.resolve(forOptionalType: SecurityAreaActionProtocol.self) {
            actionsProvider.getActions(
                userPref: self.userPref,
                offer: videoOffer,
                deviceState: validatedDeviceState,
                completion: { [weak self] views in
                    guard let strongSelf = self else { return }
                    strongSelf.view?.setSecurityAreaActions(views)
                    strongSelf.state = .everythingLoaded
                })
        }
    }
    
    func updateBiometryPreferences() {
        userPref.biometryType = biometryConfigurator.getBiometryType()
        userPref.isAuthEnabled = biometryConfigurator.isBiometryAvailable() && biometryConfigurator.isBiometryEnabled()
        userPref.isKeychainBiometryEnabled = biometryConfigurator.isBiometryAvailable()
    }
 
    func executeContactOffer(_ action: SecurityActionType) {
        let contactOffer = self.offers.location(key: SecurityAreaPullOffers.contact)?.offer
        self.coordinatorDelegate.didSelectOffer(contactOffer)
    }
    
    func goToOperabilityChange() {
        self.state = .shouldLoad
        self.coordinator.goToOperabilityChange()
    }
    
    func trackActionEvent(_ action: SecurityActionType) {
        switch action {
        case .secureDevice:
            trackEvent(.otpPush, parameters: [:])
        case .operativeUser:
            trackEvent(.user, parameters: [:])
        case .changePassword:
            trackEvent(.accessKey, parameters: [:])
        case .changeSignature:
            trackEvent(.multichannelSign, parameters: [:])
        case .accountMovement:
            trackEvent(.user, parameters: [:])
        default:
            break
        }
    }
    
    func showLisboaLocationPermissionsDialog(acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let info = LocationPermissionsPromptDialogData.getLocationDialogInfo(acceptAction: acceptAction,
                                                                             cancelAction: cancelAction
        )
        let identifiers = LocationPermissionsPromptDialogData.getLocationDialogIdentifiers()
        personalAreaCoordinator.showPromptDialog(info: info,
                                                 identifiers: identifiers,
                                                 closeButtonEnabled: false
        )
    }
    
    func showNativeLocationPermissions() {
        self.locationPermission.setLocationPermissions( completion: { [weak self] in
            self?.didAskLocationPermissions()
        }, cancelledCompletion: { [weak self] in
            self?.loadPersonalInformation()
        })
    }
    
    func didAskLocationPermissions() {
        self.loadPersonalInformation {
            guard self.userPref.isGeolocalizationEnabled ?? false else { return }
            Async.main {
                self.personalAreaCoordinator.showAlert(
                    with: localized("security_alert_activateLocation"),
                    messageType: .info
                )
            }
        }
    }
}

extension SecurityAreaPresenter: GlobalSecurityViewDataComponentsProtocol { }
