import Foundation

public struct CardApplePayStatusDTO: Codable {
    
    public enum Status: String, Codable {
        case active = "A"
        case deactivated = "D"
        case enrollable = "E"
        case notEnrollable = "N"
    }
    
    public let status: Status
    
    public init(status: Status) {
        self.status = status
    }
}
