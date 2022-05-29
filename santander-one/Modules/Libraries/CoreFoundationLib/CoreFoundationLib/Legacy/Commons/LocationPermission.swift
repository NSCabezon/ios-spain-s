//
//  LocationPermission.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 1/29/20.
//

import Foundation

public protocol LocationPermissionSettingsProtocol: AnyObject {
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cancelAction:(() -> Void)?)
}

public final class LocationPermission {
    let dependenciesResolver: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    private var locationPermissionSettings: LocationPermissionSettingsProtocol? {
        self.dependenciesResolver.resolve(for: LocationPermissionSettingsProtocol.self)
    }
    
    private var locationPermissionManager: LocationPermissionsManagerProtocol? {
        return self.dependenciesResolver.resolve(for: LocationPermissionsManagerProtocol.self)
    }
    
    public func isLocationAccessEnabled() -> Bool {
        guard let locationManager = locationPermissionManager else { return false }
        return locationManager.isLocationAccessEnabled()
    }
    
    public func getCurrentLocation(completion: @escaping ((_ latitude: Double?, _ longitude: Double?) -> Void)) {
        guard let locationManager = locationPermissionManager else {
            completion(nil, nil)
            return
        }
        return locationManager.getCurrentLocation(completion: completion)
    }
    
    public func setLocationPermissions(_ completion:(() -> Void)?) {
        guard let locationManager = locationPermissionManager else { return }
        if locationManager.isAlreadySet {
            DispatchQueue.main.async {
                self.locationPermissionSettings?
                    .goToSettings(acceptTitle: localized("genericAlert_buttom_settings"),
                                  cancelTitle: localized("generic_button_cancel"),
                                  title: localized("generic_title_permissionsDenied"),
                                  body: localized("onboarding_alert_text_permissionActivation"),
                                  cancelAction: completion)
            }
        } else {
            locationManager.askAuthorizationIfNeeded {
                locationManager.setGlobalLocationAsked()
                completion?()
            }
        }
    }
    
    public func setLocationPermissions(completion:(() -> Void)?, cancelledCompletion: (() -> Void)?) {
        guard let locationManager = locationPermissionManager else { return }
        if locationManager.isAlreadySet {
            DispatchQueue.main.async {
                self.locationPermissionSettings?
                    .goToSettings(acceptTitle: localized("genericAlert_buttom_settings"),
                                  cancelTitle: localized("generic_button_cancel"),
                                  title: localized("generic_title_permissionsDenied"),
                                  body: localized("onboarding_alert_text_permissionActivation"),
                                  cancelAction: cancelledCompletion)
            }
        } else {
            locationManager.askAuthorizationIfNeeded {
                locationManager.setGlobalLocationAsked()
                completion?()
            }
        }
    }
    
    public func setLocationPermissionsIfNotAsked(_ completion:(() -> Void)?) {
        guard let locationManager = locationPermissionManager else { return }
        if locationManager.isAlreadySet {
            completion?()
        } else {
            locationManager.askAuthorizationIfNeeded {
                locationManager.setGlobalLocationAsked()
                completion?()
            }
        }
    }
}
