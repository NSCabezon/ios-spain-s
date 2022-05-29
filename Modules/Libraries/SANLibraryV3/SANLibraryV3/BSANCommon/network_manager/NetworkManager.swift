import Foundation

public protocol NetworkManager {
    
    func checkWifi() -> Bool
    
    func checkConnectivity() throws
    
}
