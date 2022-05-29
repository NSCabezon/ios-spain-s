//
//  PersonalAreaMainModulePresenter.swift
//  PersonalArea
//
//  Created by alvola on 06/03/2020.
//

import CoreFoundationLib

public protocol PersonalAreaMainModuleModifier {
    func getName() -> String
}

protocol PersonalAreaMainModulePresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: PersonalAreaMainModuleViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator? { get set }
    func viewDidLoad()
    func viewBecomeActive()
    func backButtonAction()
    func searchAction()
    func drawerAction()
    func cameraAction()
    func userInfoAction()
}

final class PersonalAreaMainModulePresenter {
    weak var view: PersonalAreaMainModuleViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    
    let dependenciesResolver: DependenciesResolver
    
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalArea
    }
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    
    private lazy var photoHelper: PhotoHelper = {
        let helper = PhotoHelper(delegate: self)
        helper.compressionQuality = 0.6
        return helper
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    // MARK: - privateMethods
    
    private func loadPersonalAreaPreferences() {
        self.getAvatarImage()
        self.dataManager?.loadPersonalAreaPreferences({ [weak self] in
            self?.getPullOffers {
                self?.view?.setUserPref(self?.dataManager?.getUserPreference())
            }
        })
    }
    
    private func getAvatarImage() {
        self.dataManager?.getAvatarImage({ [weak self] (result) in
            guard let data = result.image else { return }
            self?.view?.setAvatarImage(data: data)
            }, failure: { _ in })
    }
}

extension PersonalAreaMainModulePresenter: PersonalAreaMainModulePresenterProtocol {
    func viewDidLoad() {
        getIsSearchEnabled()
        self.trackScreen()
    }
    
    func viewBecomeActive() {
        loadPersonalAreaPreferences()
    }
    
    func drawerAction() {
        personalAreaModuleCoordinator?.didSelectMenu()
    }
    
    func backButtonAction() {
        personalAreaModuleCoordinator?.didSelectDismiss()
    }
    
    func searchAction() {
        guard localAppConfig.isEnabledMagnifyingGlass else {
            self.view?.showComingSoonToast()
            return
        }
        personalAreaModuleCoordinator?.didSelectSearch()
    }
    
    func cameraAction() {
        personalAreaModuleCoordinator?.performAvatarChange(
            cameraTitle: localized("customizeAvatar_button_camera"),
            cameraRollTitle: localized("customizeAvatar_button_photos"),
            title: localized("customizeAvatar_popup_title_select"),
            body: localized("customizeAvatar_popup_text_select"),
            cameraAction: { [weak self] in
                self?.photoHelper.askImage(type: .camera)
                self?.trackPhoto(PersonaAreaPhotoPage.Action.camera.rawValue)
            },
            cameraRollAction: { [weak self] in
                self?.photoHelper.askImage(type: .photoLibrary)
                self?.trackPhoto(PersonaAreaPhotoPage.Action.gallery.rawValue)
        })
        self.trackEvent(.photo, parameters: [:])
    }
    
    func userInfoAction() {
        trackEvent(.name, parameters: [:])
        moduleCoordinatorNavigator?.goToUserDataSection()
    }
}

extension PersonalAreaMainModulePresenter: PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate {
    func didSelect(_ section: PersonalAreaSection) {
        switch section {
        case .userData:
            moduleCoordinatorNavigator?.goToUserDataSection()
        case .digitalProfile:
            trackEvent(.digitalProfile, parameters: [:])
            moduleCoordinatorNavigator?.goToDigitalProfile()
        case .configuration:
            trackEvent(.configuration, parameters: [:])
            moduleCoordinatorNavigator?.goToConfigurationSection()
        case .security:
            trackEvent(.security, parameters: [:])
            self.didSelectSecurity()
        case .documentation:
            trackEvent(.documentation, parameters: [:])
            self.didSelectOffer()
        case .recovery:
            self.didSelectRecoveryOffer()
        case .pgPersonalization:
            moduleCoordinatorNavigator?.goToPGCustomization()
        default:
            break
        }
    }
    
    func valueDidChange(_ action: PersonalAreaAction, value: Any) {
        
    }
}

extension PersonalAreaMainModulePresenter: PhotoPickerPresenter {
    
    private var pushNotificationPermissionManager: PushNotificationPermissionsManagerProtocol? {
        let configuration: PersonalAreaConfiguration = dependenciesResolver.resolve(for: PersonalAreaConfiguration.self)
        return configuration.pushNotificationPermissionsManager
    }
    var viewForPresentation: UIViewController? { view }
    
    func selected(image: Data) {
        dataManager?.setUserAvatarImage(image, onSuccess: { [weak self] in
            self?.view?.setAvatarImage(data: image)
            NotificationCenter.default.post(name: Notification.Name.didChangeAvatarImage, object: nil)
        })
    }
    
    func showError(error: PhotoHelperError) {
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        self.personalAreaModuleCoordinator?.goToSettings(acceptTitle: localized("genericAlert_buttom_settings"),
                                                   cancelTitle: localized("generic_button_cancel"),
                                                   title: localized("generic_title_permissionsDenied"),
                                                   body: localized(keyDesc)) {
                                                    [weak self] in self?.getNotificationPermissions() }
    }
    
    private func getNotificationPermissions() {
        pushNotificationPermissionManager?.isNotificationsEnabled(completion: { [weak self] resp in
            let userPref = self?.dataManager?.getUserPreference()
            userPref?.isNotificationEnable = resp
            DispatchQueue.main.async {
                self?.view?.setUserPref(userPref)
            }
        })
    }
}

extension PersonalAreaMainModulePresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: PersonalAreaPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.personalAreaEventID
        return PersonalAreaPage(emmaToken: emmaToken)
    }
}

extension PersonalAreaMainModulePresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

private extension PersonalAreaMainModulePresenter {
    func getPullOffers(_ completion: @escaping () -> Void) {
        dataManager?.getAvailablePullOffers(locations, onSuccess: { [weak self] response in
            guard let userPref = self?.dataManager?.getUserPreference(),
                userPref.isPersonalDocEnabled == true else { return completion() }
            userPref.isPersonalDocOfferEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.personalAreaDocumentary })
            userPref.isRecoveryOfferEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.recovery })
            self?.pullOfferCandidates = response?.pullOfferCandidates ?? [:]
            completion()
        })
    }
    
    func didSelectOffer() {
        if let first = self.pullOfferCandidates.first(where: { $0.key.stringTag == PersonalAreaPullOffers.personalAreaDocumentary }) {
            self.personalAreaModuleCoordinator?.didSelectOffer(offer: first.value)
        }
    }
    
    func didSelectRecoveryOffer() {
        if let first = self.pullOfferCandidates.first(where: { $0.key.stringTag == PersonalAreaPullOffers.recovery }) {
            self.personalAreaModuleCoordinator?.didSelectOffer(offer: first.value)
        }
    }
    
    func trackPhoto(_ eventId: String) {
        var trackerPagePhoto: PersonaAreaPhotoPage {
            return PersonaAreaPhotoPage()
        }
        self.trackerManager.trackEvent(screenId: trackerPagePhoto.page, eventId: eventId, extraParameters: [:])
    }
    
    func didSelectSecurity() {
        if localAppConfig.isEnabledSecurityArea {
            moduleCoordinatorNavigator?.goToSecuritySection()
        } else {
            self.view?.showComingSoonToast()
        }
    }
}
