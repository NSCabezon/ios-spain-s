import CoreFoundationLib
import Localization

final public class LocationPermissionsManagerMock: LocationPermissionsManagerProtocol {
    public func locationServicesStatus() -> LocationStatus {
        return .authorized
    }
    
    public func isLocationAccessEnabled() -> Bool {
        return true
    }
    
    public var isAlreadySet: Bool {
        true
    }
    
    public func askAuthorizationIfNeeded(completion: @escaping () -> Void) {
        completion()
    }
    
    public func setGlobalLocationAsked() {
        
    }
    
    public func getCurrentLocation(completion: @escaping ((Double?, Double?) -> Void)) {
        completion(43.54523, -5.66192)
    }
}
