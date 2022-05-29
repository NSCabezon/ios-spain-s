

public final class SharedKeyChainService: KeychainService {
    public let account = "installationDataToShare"
    public let service = "Santander"
    public let accessGroupName: String?
    
    public init(accessGroupName: String?) {
        self.accessGroupName = accessGroupName
    }
}
