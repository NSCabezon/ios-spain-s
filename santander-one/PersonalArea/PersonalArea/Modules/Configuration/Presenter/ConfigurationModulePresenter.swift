//
//  ConfigurationModulePresenter.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import CoreFoundationLib

protocol ConfigurationPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: ConfigurationViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator? { get set }
    var moduleCoordinator: DefaultConfigurationModuleCoordinator? { get set }
    
    func viewDidLoad()
    func viewBecomeActive()
    func backButtonAction()
    func searchAction()
    func drawerAction()
}

final class ConfigurationModulePresenter {
    weak var view: ConfigurationViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: DefaultConfigurationModuleCoordinator?
    
    let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    private var pushNotificationPermissionManager: PushNotificationPermissionsManagerProtocol? {
        let configuration: PersonalAreaConfiguration = dependenciesResolver.resolve(for: PersonalAreaConfiguration.self)
        return configuration.pushNotificationPermissionsManager
    }
        
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalAreaAlertsConfig
    }
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    // MARK: - privateMethods
    
    private func setNotificationPermissions() {
        guard let pushManager = pushNotificationPermissionManager else { return }
        pushManager.isAlreadySet { [weak self] isAlreadySet in
            if isAlreadySet {
                Async.main {
                    self?.personalAreaModuleCoordinator?.goToSettings(
                        acceptTitle: localized("genericAlert_buttom_settings"),
                        cancelTitle: localized("generic_button_cancel"),
                        title: localized("generic_title_permissionsDenied"),
                        body: localized("onboarding_alert_text_permissionActivation")
                    ) { [weak self] in
                        self?.getNotificationPermissions()
                    }
                }
            } else {
                pushManager.requestAccess { [weak self] _ in self?.getNotificationPermissions(true) }
            }
        }
    }
    
    private func getNotificationPermissions(_ trackNotifications: Bool = false) {
        self.pushNotificationPermissionManager?.isNotificationsEnabled { [weak self] isNotificationsEnabled in
            let userPref = self?.dataManager?.getUserPreference()
            userPref?.isNotificationEnable = isNotificationsEnabled
            Async.main {
                self?.view?.setUserPref(userPref, dependenciesResolver: self?.dependenciesResolver)
            }
            guard let presenter = self, trackNotifications else { return }
            presenter.trackEvent(isNotificationsEnabled ? .notificationsOn: .notificationsOff, parameters: [:])
        }
    }
    
    private func loadPersonalAreaPreferences() {
        self.dataManager?.loadPersonalAreaPreferences { [weak self] in
            self?.view?.setUserPref(self?.dataManager?.getUserPreference(), dependenciesResolver: self?.dependenciesResolver)
            self?.getNotificationPermissions(false)
        }
    }
    
    private func getPullOffers() {
        self.dataManager?.getAvailablePullOffers(locations) { [weak self] response in
            guard let userPref = self?.dataManager?.getUserPreference() else { return }
            userPref.isConfigureAlertsEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.configAlerts })
            self?.dataManager?.updateUserPref(userPref)
            self?.view?.setUserPref(userPref, dependenciesResolver: self?.dependenciesResolver)
            self?.pullOfferCandidates = response?.pullOfferCandidates ?? [:]
        }
    }
    
    private func goToPullOffer(_ offerTag: String) {
        if let first = self.pullOfferCandidates.first(where: { $0.key.stringTag == offerTag }) {
            self.personalAreaModuleCoordinator?.didSelectOffer(offer: first.value)
        }
    }
}

extension ConfigurationModulePresenter: ConfigurationPresenterProtocol {
    func viewDidLoad() {
        self.view?.setUserPref(dataManager?.getUserPreference(), dependenciesResolver: self.dependenciesResolver)
        self.getPullOffers()
        self.getIsSearchEnabled()
    }
    
    func viewBecomeActive() {
        self.loadPersonalAreaPreferences()
    }
    
    func drawerAction() {
        self.personalAreaModuleCoordinator?.didSelectMenu()
    }
    
    func backButtonAction() {
        self.moduleCoordinator?.end()
    }
    
    func searchAction() {
        guard self.localAppConfig.isEnabledMagnifyingGlass else {
            self.view?.showComingSoonToast()
            return
        }
        self.personalAreaModuleCoordinator?.didSelectSearch()
    }
}

extension ConfigurationModulePresenter: PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate {
    func didSelect(_ section: PersonalAreaSection) {
        switch section {
        case .languageSelection:
            self.trackEvent(.language, parameters: [:])
            self.moduleCoordinator?.goToLanguageSelection()
        case .pgPersonalization:
            self.moduleCoordinator?.goToGPCustomization()
        case .photoTheme:
            self.trackEvent(.photo, parameters: [:])
            self.moduleCoordinator?.goToPhotoThemeSelector()
        case .appInfo:
            self.trackEvent(.appInfo, parameters: [:])
            self.moduleCoordinator?.goToAppInfo()
        case .appPermissions:
            self.trackEvent(.appPermissions, parameters: [:])
            self.moduleCoordinator?.goToAppPermissions()
        case .alertsConfiguration:
            if self.localAppConfig.isEnabledConfigureAlertsInMenu == true {
                self.view?.showComingSoonToast()
            } else {
                self.goToPullOffer("AREA_PERSONAL_CONFIG_ALERTAS")
            }
        default:
            self.view?.showComingSoonToast()
        }
    }
    
    func valueDidChange(_ action: PersonalAreaAction, value: Any) {
        switch action {
        case .notificationPermission:
            self.setNotificationPermissions()
        default: break
        }
    }
}

extension ConfigurationModulePresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        self.getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

extension ConfigurationModulePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: PersonalAreaConfigurationPage {
        return PersonalAreaConfigurationPage()
    }
}
