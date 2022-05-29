public struct KeychainQuery {
    let service: String?
    let account: String?
    let label: String?
    let accessGroup: String?
    let data: NSCoding?
    
    public var archivedData: Data? {
        guard let data = self.data else { return nil }
        return NSKeyedArchiver.archivedData(withRootObject: data)
    }
    
    public func unarchiveData(_ data: Data?) -> NSCoding? {
        guard let data = data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
    }
    
    public init(service: String? = nil,
                account: String? = nil,
                label: String? = nil,
                accessGroup: String? = nil,
                data: NSCoding? = nil) {
        self.service = service
        self.account = account
        self.label = label
        self.accessGroup = accessGroup
        self.data = data
    }
    
    public init(compilation: CompilationProtocol, accountPath: KeyPath<CompilationProtocol, String>, data: NSCoding? = nil) {
        self.init(service: compilation.keychain.service,
                  account: compilation[keyPath: accountPath],
                  accessGroup: compilation.keychain.sharedTokenAccessGroup,
                  data: data)
    }
    
    public func unwrappedDictionary(extraFields: [AnyHashable: Any]? = nil) -> [AnyHashable: Any] {
        var paramsUnwrapped: [AnyHashable: Any] =
            [kSecClass: kSecClassGenericPassword,
             kSecAttrSynchronizable: kSecAttrSynchronizableAny]
        if let account = self.account {
            paramsUnwrapped[kSecAttrAccount] = account
        }
        if let service = self.service {
            paramsUnwrapped[kSecAttrService] = service
        }
        if let label = self.label {
            paramsUnwrapped[kSecAttrLabel] = label
        }
        if let accessGroup = self.accessGroup {
            paramsUnwrapped[kSecAttrAccessGroup] = accessGroup
        }
        if let archivedData = self.archivedData {
            paramsUnwrapped[kSecValueData] = archivedData
        }
        if let extraFields = extraFields {
            extraFields.forEach {
                paramsUnwrapped[$0] = $1
            }
        }
        return paramsUnwrapped
    }
}
