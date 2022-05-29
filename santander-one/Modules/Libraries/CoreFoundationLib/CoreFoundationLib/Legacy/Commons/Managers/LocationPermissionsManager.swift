//
//  LocationPermissionsManager.swift
//  Commons
//
//  Created by Tania Castellano Brasero on 09/12/2019.
//

public enum LocationStatus {
    case denied
    case authorized
    case notDetermined
}

public protocol LocationPermissionsManagerProtocol: AnyObject {
    func isLocationAccessEnabled() -> Bool
    var isAlreadySet: Bool { get }
    func askAuthorizationIfNeeded(completion: @escaping () -> Void)
    func setGlobalLocationAsked()
    func getCurrentLocation(completion: @escaping ((_ latitude: Double?, _ longitude: Double?) -> Void))
    func locationServicesStatus() -> LocationStatus
}
