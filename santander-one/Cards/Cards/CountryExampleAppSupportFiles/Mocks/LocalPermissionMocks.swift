//
//  LocalPermissionMocks.swift
//  Cards
//
//  Created by alvola on 22/09/2021.
//

import CoreFoundationLib
import CoreLocation

final class SpyLocationPermissionsManager: LocationPermissionsManagerProtocol {
    
    var isAlreadySet: Bool = false
    var firsTimeAskingForLocation: Bool = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    func locationServicesStatus() -> LocationStatus {
        return .authorized
    }
    
    func isLocationAccessEnabled() -> Bool {
        return authorizationStatus == .authorizedAlways
            || authorizationStatus == .authorizedWhenInUse
    }
    
    func askAuthorizationIfNeeded(completion: @escaping () -> Void) {
        self.firsTimeAskingForLocation = (authorizationStatus == .notDetermined)
        completion()
    }
    
    func setGlobalLocationAsked() {
        self.isAlreadySet = true
    }
    
    func getCurrentLocation(completion: @escaping ((Double?, Double?) -> Void)) {
        
    }
}

final class SpyLocationPermissionSettings: LocationPermissionSettingsProtocol {
    var successGotoSettings: Bool = false
    
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cancelAction: (() -> Void)?) {
        self.successGotoSettings = true
    }
}
