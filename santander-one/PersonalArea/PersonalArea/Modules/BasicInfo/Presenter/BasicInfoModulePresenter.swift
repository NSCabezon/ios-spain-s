//
//  BasicInfoModulePresenter.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import CoreFoundationLib
import UI

public protocol PersonalInfoModifierProtocol {
    var maskInfo: Bool { get }
}

protocol BasicInfoPresenterProtocol: AnyObject {
    var view: BasicInfoViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator? { get set }
    
    func viewDidLoad()
    func viewBecomeActive()
    func backDidPress()
    func closeDidPress()
    func cameraDidPress()
}

final class BasicInfoModulePresenter {
    weak var view: BasicInfoViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: DefaultBasicInfoModuleCoordinator?
    
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private lazy var photoHelper: PhotoHelper = {
        let helper = PhotoHelper(delegate: self)
        helper.compressionQuality = 0.6
        return helper
    }()
    private var loadableView: LoadingViewPresentationCapable? {
        return self.view
    }
    
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalAreaNamePage
    }
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: - private Methods
    
    private func loadUserPref() {
        loadableView?.showLoading(completion: { [weak self] in
            self?.dataManager?.loadPersonalAreaPreferences { [weak self] in
                self?.getBasicInfo()
            }
        })
    }
    
    private func getBasicInfo() {
        dataManager?.getUserBasicInfo(onSuccess: { [weak self] resp in
            guard let self = self else { return }
            let userPref = self.dataManager?.getUserPreference()
            if let personalInformation = resp.personalInformation {
                let birth = dateToString(date: personalInformation.birthDate, outputFormat: .asteriskedDate) ?? personalInformation.birthString
                self.updateIsConfigurated(email: personalInformation.email,
                                          phone: personalInformation.phoneNumber)
                var maskInfo = true
                if let personalInfoModifier = self.dependenciesResolver.resolve(forOptionalType: PersonalInfoModifierProtocol.self) {
                    maskInfo = personalInfoModifier.maskInfo
                }
                userPref?.personalInfo = PersonalInfoWrapper(maskInfo: maskInfo,
                                                             address: personalInformation.mainAddress,
                                                             addressNodes: personalInformation.addressNodes,
                                                             kindOfDocument: personalInformation.documentType?.rawValue,
                                                             document: personalInformation.documentNumber,
                                                             birthday: birth,
                                                             phone: personalInformation.phoneNumber,
                                                             smsPhone: personalInformation.smsPhoneNumber,
                                                             email: personalInformation.email)
                userPref?.personalInfo?.correspondenceAddressNodes = personalInformation.dto.correspondenceAddressNodes
            }
            self.view?.setUserPref(userPref, dependencies: self.dependenciesResolver)
            self.loadableView?.dismissLoading()
        }, failure: { [weak self] _ in
            self?.loadableView?.dismissLoading()
        })
    }
    
    private func getUserImage() {
        dataManager?.getAvatarImage({ [weak self] (resp) in
            self?.view?.setAvatarImage(data: resp.image)
        }, failure: { _ in })
    }
    
    private func updateIsConfigurated(email: String?, phone: String?) {
        guard let userPrefEntity = dataManager?.getUserPreference().userPrefEntity else { return }
        userPrefEntity.emailConfigured(!(email ?? "").isEmpty)
        userPrefEntity.phoneConfigured(!(phone ?? "").isEmpty)
        dataManager?.updateUserPreferencesValues(userPrefEntity: userPrefEntity, onSuccess: nil, onError: nil)
    }
    
    private func getPullOffers() {
        dataManager?.getAvailablePullOffers(locations, onSuccess: { [weak self] response in
            guard let userPref = self?.dataManager?.getUserPreference() else { return }
            userPref.editPersonalInfoEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.contactData })
            userPref.editDNIEnabled = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.contactDataDNI })
            let isEnabledConsentManagement = self?.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledConsentManagement
            userPref.manageGDPR = (response?.pullOfferCandidates ?? [:]).keys.contains(where: { $0.stringTag == PersonalAreaPullOffers.gdpr }) && (isEnabledConsentManagement ?? false)
            self?.dataManager?.updateUserPref(userPref)
            self?.view?.setUserPref(userPref, dependencies: self?.dependenciesResolver)
            self?.pullOfferCandidates = response?.pullOfferCandidates ?? [:]
        })
    }
    
    private func aliasDidChange(_ newAlias: String) {
        guard let userPref = dataManager?.getUserPreference(), let userPrefEntity = userPref.userPrefEntity else { return }
        self.view?.showLoading(completion: { [weak self] in
            let alias = newAlias.isBlank ? "" : newAlias
            userPrefEntity.setUserAlias(alias)
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPrefEntity, onSuccess: { [weak self] in
                self?.dataManager?.loadPersonalAreaPreferences {
                    self?.view?.setUserPref(self?.dataManager?.getUserPreference(), dependencies: self?.dependenciesResolver)
                    self?.view?.dismissLoading()
                }
            }, onError: { [weak self] _ in
                self?.view?.dismissLoading()
            })
        })
        self.trackEvent(.save, parameters: [:])
    }
}

private extension BasicInfoModulePresenter {
    func goToEditFieldOnline(_ offerTag: String, section: PersonalAreaSection) {
        if let first = self.pullOfferCandidates.first(where: { $0.key.stringTag == offerTag }) {
            self.personalAreaModuleCoordinator?.didSelectOffer(offer: first.value)
        }
    }
    
    func trackPhoto(_ eventId: String) {
        var trackerPagePhoto: PersonaAreaNamePhotoPage {
            return PersonaAreaNamePhotoPage()
        }
        self.trackerManager.trackEvent(screenId: trackerPagePhoto.page, eventId: eventId, extraParameters: [:])
    }
}

extension BasicInfoModulePresenter: BasicInfoPresenterProtocol {
    
    func viewDidLoad() {
        getUserImage()
        self.trackScreen()
    }
    
    func viewBecomeActive() {
        loadUserPref()
        getPullOffers()
    }
    
    func backDidPress() {
        moduleCoordinator?.end()
    }
    
    func closeDidPress() {
        moduleCoordinator?.end()
    }
    
    func cameraDidPress() {
        personalAreaModuleCoordinator?.performAvatarChange(
            cameraTitle: localized("customizeAvatar_button_camera"),
            cameraRollTitle: localized("customizeAvatar_button_photos"),
            title: localized("customizeAvatar_popup_title_select"),
            body: localized("customizeAvatar_popup_text_select"),
            cameraAction: { [weak self] in
                self?.photoHelper.askImage(type: .camera)
                self?.trackPhoto(PersonaAreaNamePhotoPage.Action.camera.rawValue)
            },
            cameraRollAction: { [weak self] in
                self?.photoHelper.askImage(type: .photoLibrary)
                self?.trackPhoto(PersonaAreaNamePhotoPage.Action.gallery.rawValue)
        })
        self.trackEvent(.photo, parameters: [:])
    }
}

extension BasicInfoModulePresenter: PersonalAreaTableViewControllerDelegate {
    func didSelect(_ section: PersonalAreaSection) {
        let localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
        switch section {
        case .editEmail, .editPhone, .editAddress:
            if localAppConfig.isEnabledPersonalData == true {
                 self.view?.showComingSoonToast()
             } else {
                 goToEditFieldOnline("DATOS_CONTACTO", section: section)
             }
        case .editGDPR:
            goToEditFieldOnline("GDPR", section: section)
        case .editDNI:
            goToEditFieldOnline("DATOS_CONTACTO_DNI", section: section)
        default:
            Toast.show("Próximamente")
        }
    }
}

extension BasicInfoModulePresenter: PersonalAreaActionCellDelegate {
    func valueDidChange(_ action: PersonalAreaAction, value: Any) {
        switch action {
        case .alias:
            guard let stringValue = value as? String else { return }
            aliasDidChange(stringValue)
        case .editText:
            self.trackEvent(.edit, parameters: [:])
        default: break
        }
    }
}

extension BasicInfoModulePresenter: PhotoPickerPresenter {
    
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
                self?.view?.setUserPref(userPref, dependencies: self?.dependenciesResolver)
            }
        })
    }
}

extension BasicInfoModulePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: PersonalAreaNamePage {
        return PersonalAreaNamePage()
    }
}
