//
//  MockLocationPermissionsManager.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreFoundationLib

final class MockLocationPermissionsManager: LocationPermissionsManagerProtocol {
    func isLocationAccessEnabled() -> Bool {
        return false
    }
    
    var isAlreadySet: Bool = false
    
    func askAuthorizationIfNeeded(completion: @escaping () -> Void) {}
    
    func setGlobalLocationAsked() {}
    
    func getCurrentLocation(completion: @escaping ((Double?, Double?) -> Void)) {}
    
    func locationServicesStatus() -> LocationStatus {
        return .authorized
    }
}
