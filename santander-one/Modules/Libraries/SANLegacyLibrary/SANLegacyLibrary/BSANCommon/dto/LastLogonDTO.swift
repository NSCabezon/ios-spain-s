import Foundation

public struct LastLogonDTO: Codable {
    public var lastConnection: String?
    public var lastLogonDate: String?
    public var lastFailedLogonDate: String?
    public var uid: String?
    
    public init() {}
}
