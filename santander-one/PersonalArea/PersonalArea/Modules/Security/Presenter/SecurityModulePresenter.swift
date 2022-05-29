//
//  SecurityModulePresenter.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol SecurityPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: SecurityViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinator: DefaultSecurityModuleCoordinator? { get set }
    
    func viewDidLoad()
    func viewBecomeActive()
    func backButtonAction()
    func searchAction()
    func drawerAction()
    func loadSecurityCells(_ userPref: UserPrefWrapper?)
}

final class SecurityModulePresenter {
    weak var view: SecurityViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinator: DefaultSecurityModuleCoordinator?
    private var userPref: UserPrefWrapper
    
    let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private lazy var locationPermission: LocationPermission = {
        return self.dependenciesResolver.resolve(for: LocationPermission.self)
    }()
    
    private lazy var biometryConfigurator: BiometryConfigurator = {
        BiometryConfigurator(dependenciesResolver: dependenciesResolver)
    }()
    
    private lazy var biometryAction: PersonalAreaBiometryAction = {
        return PersonalAreaBiometryAction(dependenciesResolver: dependenciesResolver)
    }()

    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalAreaNamePage
    }
    
    private var lastAccessManager: LastAccessInfoManagerProtocol {
        return dependenciesResolver.resolve(for: LastAccessInfoManagerProtocol.self)
    }
    
    private lazy var personalAreaSectionsSecurityModifier: PersonalAreaSectionsSecurityModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: PersonalAreaSectionsSecurityModifierProtocol.self)
    }()
    
    private var isESignatureFunctionalityEnabled: Bool {
        guard let isESignatureFunctionalityEnabled = personalAreaSectionsSecurityModifier?.isESignatureFunctionalityEnabled else {
            return true
        }
        return isESignatureFunctionalityEnabled
    }
    
    private var isBiometryFunctionalityEnabled: Bool {
        guard let isBiometryFunctionalityEnabled = personalAreaSectionsSecurityModifier?.isBiometryFunctionalityEnabled else {
            return true
        }
        return isBiometryFunctionalityEnabled
    }
    
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.userPref = self.dependenciesResolver.resolve(for: UserPrefWrapper.self)
    }
}

extension SecurityModulePresenter: SecurityPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        getIsSearchEnabled()
        updateLastAccess(nil)
        loadSecurityCells(dataManager?.getUserPreference())
    }
    
    func viewBecomeActive() {
        loadPersonalAreaPreferences()
        getPullOffers()
        getLastLogonDate()
    }
    
    func drawerAction() {
        personalAreaModuleCoordinator?.didSelectMenu()
    }
    
    func backButtonAction() {
        moduleCoordinator?.end()
    }
    
    func searchAction() {
        let localAppConfig = self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        guard localAppConfig.isEnabledMagnifyingGlass else {
            self.view?.showComingSoonToast()
            return
        }
        personalAreaModuleCoordinator?.didSelectSearch()
    }
    
    func loadSecurityCells(_ userPref: UserPrefWrapper?) {
        updateBiometryPreferences(userPref)
        if let sectionsProvider = dependenciesResolver.resolve(forOptionalType: PersonalAreaSectionsProtocol.self) {
            sectionsProvider.getSecuritySectionCells(userPref) { [weak self] cells in
                self?.view?.setCellsInfo(cells)
            }
        } else {
            self.view?.setCellsInfo(
                PersonalAreaSection.security.cellsDictionaryWith(userPref) ?? []
            )
        }
    }
    
    func updateBiometryPreferences(_ userPref: UserPrefWrapper?) {
        userPref?.biometryType = biometryConfigurator.getBiometryType()
        userPref?.isAuthEnabled = biometryConfigurator.isBiometryAvailable() && biometryConfigurator.isBiometryEnabled()
        userPref?.isKeychainBiometryEnabled = biometryConfigurator.isBiometryAvailable()
    }
}

extension SecurityModulePresenter: PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate {
    func didSelect(_ section: PersonalAreaSection) {
        switch section {
        case .secureDevice:
            trackEvent(.secureDevice, parameters: [:])
            goToSecureDevice()
        case .operativeUser:
            self.trackEvent(.user, parameters: [:])
            moduleCoordinator?.goToOperabilityChange()
        case .signature:
            self.trackEvent(.accessKey, parameters: [:])
            if isESignatureFunctionalityEnabled {
                self.moduleCoordinator?.goToSignature()
            } else {
                view?.showComingSoonToast()
            }
        case .changePassword:
            self.trackEvent(.accessKey, parameters: [:])
            self.moduleCoordinator?.goToChangePassword()
        case .editGDPR:
            self.trackEvent(.consents, parameters: [:])
            self.goToManageGDPR("GDPR", section: section)
        case .quickerBalance, .password, .changePIN:
            moduleCoordinator?.goToSecurityCustomAction()
        case .wayCommunication, .cookiesSettings, .dataPrivacy:
            self.view?.showComingSoonToast()
        default:
            view?.showComingSoonToast()
        }
    }
    
    func valueDidChange(_ action: PersonalAreaAction, value: Any) {
        switch action {
        case .geolocalization:
            if value as? Bool == true {
                self.trackEvent(.geolocationOn, parameters: [:])
                askLocationPermissions()
            } else {
                self.trackEvent(.geolocationOff, parameters: [:])
                showNativeLocationPermissions()
            }
        case .touchFaceId:
            if isBiometryFunctionalityEnabled {
                if value as? Bool == true {
                    self.trackEvent(.biometricOn, parameters: [.accessLoginType: "touchID"])
                } else {
                    self.trackEvent(.biometricOff, parameters: [:])
                }
                biometryAction.didSelectBiometry { [weak self] reload in
                    if reload { self?.loadPersonalAreaPreferences() }
                }
            } else {
                view?.showComingSoonToast()
            }
        default: break
        }
    }
}

extension SecurityModulePresenter: PersonalAreaCustomActionCellDelegate {
    func valueDidChange(_ action: CustomAction, value: Any) {
        action { [weak self] reload in
            if reload { self?.loadPersonalAreaPreferences() }
        }
    }
    
    func didSelect(_ action: CustomAction) {
        action { [weak self] reload in
            if reload { self?.loadPersonalAreaPreferences() }
        }
    }
}

extension SecurityModulePresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

extension SecurityModulePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SecurityModulePage {
        return SecurityModulePage()
    }
}

// MARK: - Private Methods
private extension SecurityModulePresenter {
    private func getPullOffers() {
        self.dataManager?.getAvailablePullOffers(locations, onSuccess: { [weak self] response in
            guard let userPref = self?.dataManager?.getUserPreference() else { return }
            userPref.editPersonalInfoEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.contactData })
            userPref.editDNIEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.contactDataDNI })
            userPref.manageGDPR = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.gdpr })
            self?.dataManager?.updateUserPref(userPref)
            self?.loadSecurityCells(userPref)
            self?.pullOfferCandidates = response?.pullOfferCandidates ?? [:]
        })
    }
    
    func loadPersonalAreaPreferences(_ completion: (() -> Void)? = nil) {
        self.dataManager?.loadPersonalAreaPreferences({ [weak self] in
            self?.loadSecurityCells(self?.dataManager?.getUserPreference())
            completion?()
        })
    }
    
    func askLocationPermissions() {
        showLisboaLocationPermissionsDialog(acceptAction: { [weak self] in
            self?.showNativeLocationPermissions()
        }, cancelAction: { [weak self] in
            self?.loadPersonalAreaPreferences()
        })
    }
    
    func showNativeLocationPermissions() {
        self.locationPermission.setLocationPermissions(completion: { [weak self] in
            self?.didAskLocationPermissions()
        }, cancelledCompletion: { [weak self] in
            self?.loadPersonalAreaPreferences()
        })
    }
    
    func didAskLocationPermissions() {
        self.loadPersonalAreaPreferences({
            guard self.userPref.isGeolocalizationEnabled ?? false else { return }
            self.personalAreaModuleCoordinator?.showAlert(with: localized("security_alert_activateLocation"), messageType: .info)
        })
    }
    
    func goToSecureDevice() {
        self.personalAreaModuleCoordinator?.showLoading(completion: { [weak self] in
            self?.dataManager?.getOTPPushDevice({ (device) in
                self?.personalAreaModuleCoordinator?.hideLoading(completion: {
                    self?.moduleCoordinator?.goToSecureDevice(device: device)
                })
            }, failure: { (error) in
                self?.personalAreaModuleCoordinator?.hideLoading(completion: {
                    self?.showError(localized(error))
                })
            })
        })
    }
    
    func showError(_ desc: LocalizedStylableText) {
        personalAreaModuleCoordinator?.showAlertDialog(acceptTitle: localized("generic_button_accept"),
                                                       cancelTitle: nil,
                                                       title: nil,
                                                       body: desc,
                                                       acceptAction: nil,
                                                       cancelAction: nil)
        
    }
    
    func goToManageGDPR(_ offerTag: String, section: PersonalAreaSection) {
        if let first = self.pullOfferCandidates.first(where: { $0.key.stringTag == offerTag }) {
            self.personalAreaModuleCoordinator?.didSelectOffer(offer: first.value)
        }
    }
    
    func getLastLogonDate() {
        lastAccessManager.getLastAccessDateViewModelIfAvailable { [weak self] lastAccessViewModel in
            self?.updateLastAccess(lastAccessViewModel)
            self?.loadSecurityCells(self?.dataManager?.getUserPreference())
        }
    }
    
    func updateLastAccess(_ lastAccessInfo: LastLogonViewModel?) {
        guard let userPref = self.dataManager?.getUserPreference() else { return }
        userPref.lastAccessInfo = lastAccessInfo
        self.dataManager?.updateUserPref(userPref)
    }
    
    func showLisboaLocationPermissionsDialog(acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let info = LocationPermissionsPromptDialogData.getLocationDialogInfo(acceptAction: acceptAction,
                                                                             cancelAction: cancelAction
        )
        let identifiers = LocationPermissionsPromptDialogData.getLocationDialogIdentifiers()
        personalAreaModuleCoordinator?.showPromptDialog(info: info,
                                                        identifiers: identifiers,
                                                        closeButtonEnabled: false
        )
    }
}
