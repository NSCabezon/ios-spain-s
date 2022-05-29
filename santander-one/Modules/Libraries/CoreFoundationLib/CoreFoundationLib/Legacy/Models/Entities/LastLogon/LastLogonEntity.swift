import SANLegacyLibrary

public struct GetLastLogonInfoEntity {
    public let lastConnection: Date?
    public let uid: String?
    
    public init(lastConnection: Date?, uid: String?) {
        self.lastConnection = lastConnection
        self.uid = uid
    }
}
