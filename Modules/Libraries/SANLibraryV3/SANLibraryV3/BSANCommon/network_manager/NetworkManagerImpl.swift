import Foundation

public class NetworkManagerImpl : NetworkManager {
    
    
    public func checkWifi() -> Bool {
        // return if current connection is Wifi type
        return false
    }
    
    public func checkConnectivity() throws {
        // check internet and throw BSANNetworkException if is unavailable
    }
}
