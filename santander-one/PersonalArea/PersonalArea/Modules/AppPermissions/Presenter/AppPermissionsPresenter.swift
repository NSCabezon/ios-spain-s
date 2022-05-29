//
//  AppPermissionsPresenter.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 27/04/2020.
//

import CoreFoundationLib

protocol AppPermissionsPresenterProtocol: AnyObject {
    var view: AppPermissionsViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinator: DefaultAppPermissionsModuleCoordinator? { get set }
    func viewDidLoad()
    func viewBecomeActive()
    func backDidPress()
    func closeDidPress()
    func setLocationPermissions()
    func setContactsPermissions()
    func setPhotosPermissions()
    func setCameraPermissions()
    func setNotificationPermissions()
}

final class AppPermissionsPresenter {
    weak var view: AppPermissionsViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: DefaultAppPermissionsModuleCoordinator?
    
    private let configuration: PersonalAreaConfiguration
    private let localAppConfig: LocalAppConfig
    
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    private var locationPermissionManager: LocationPermissionsManagerProtocol? {
        return configuration.locationPermissionsManager
    }
    
    private var contactPermissionManager: ContactPermissionsManagerProtocol? {
        return configuration.contactsPermissionsManager
    }
    
    private var pushNotificationPermissionManager: PushNotificationPermissionsManagerProtocol? {
        return configuration.pushNotificationPermissionsManager
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = dependenciesResolver.resolve(for: PersonalAreaConfiguration.self)
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
}

extension AppPermissionsPresenter: AppPermissionsPresenterProtocol {
    func viewDidLoad() {
        self.getPermissions()
    }
    
    func viewBecomeActive() {
        self.getPermissions()
    }
        
    func backDidPress() {
         moduleCoordinator?.end()
    }
    
    func closeDidPress() {
        moduleCoordinator?.end()
    }
    
    func setLocationPermissions() {
        guard let locationManager = locationPermissionManager else { return }
        if locationManager.isAlreadySet == true {
            self.goToSettings()
        } else {
            locationManager.askAuthorizationIfNeeded(completion: { [weak self] in
                self?.getPermissions() })
        }
    }
    
    func setNotificationPermissions() {
        if localAppConfig.isEnabledNotificationsInMenu == true {
            view?.showComingSoonToast()
            view?.turnOffNotificationsSwitch()
        } else {
            guard let pushManager = pushNotificationPermissionManager else { return }
            pushManager.isAlreadySet { [weak self] isAlreadySet in
                if isAlreadySet {
                    self?.goToSettings()
                } else {
                    pushManager.requestAccess { [weak self] _ in
                        self?.getPermissions()
                    }
                }
            }
        }
    }
    
    func setContactsPermissions() {
        guard let contactsManager = contactPermissionManager else { return }
        contactsManager.isAlreadySet { [weak self] isAlreadySet in
            if isAlreadySet {
                self?.goToSettings()
            } else {
                contactsManager.askAuthorizationIfNeeded { [weak self] _ in
                    self?.getPermissions()
                }
            }
        }
    }
    
    func setPhotosPermissions() {
        let photoPermission = PhotoPermissionHelper()
        if photoPermission.isPhotoAccessAlreadySet {
            self.goToSettings()
        } else {
            photoPermission.askAuthorization(type: .photoLibraryAccess) { [weak self] _ in
                self?.getPermissions()
            }
        }
    }
    
    func setCameraPermissions() {
        let cameraPermission = PhotoPermissionHelper()
        if cameraPermission.isCameraAccessAlreadySet {
            self.goToSettings()
        } else {
            cameraPermission.askAuthorization(type: .cameraAccess) { [weak self] _ in
                self?.getPermissions()
            }
        }
    }
}

private extension AppPermissionsPresenter {
    private func getPermissions() {
        dataManager?.getPermissions({ [weak self] permissions in
            let viewModel = PermissionsViewModel(isLocationEnabled: permissions.isLocationEnabled, isContactEnabled: permissions.isContactEnabled, isPhotoEnabled: permissions.isPhotoEnabled, isCameraEnabled: permissions.isCameraEnabled, isNotificationEnabled: permissions.isNotificationEnabled)
            self?.view?.setPermissions(permission: viewModel)
        })
    }
    
    private func goToSettings() {
        self.personalAreaModuleCoordinator?.goToSettings(
            acceptTitle: localized("genericAlert_buttom_settings"),
            cancelTitle: localized("generic_button_cancel"),
            title: localized("generic_title_permissionsDenied"),
            body: localized("onboarding_alert_text_permissionActivation")) {
                [weak self] in self?.getPermissions()
        }
    }
}
