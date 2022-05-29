import Foundation

import Security

private enum Security {
    static let account = kSecAttrAccount as String
    static let service = kSecAttrService as String
    static let label = kSecAttrLabel as String
    static let data = kSecValueData as String
}

internal class Query {
    // MARK: - Query initializers methods
    
    fileprivate var payload = [String : Any]()
    
    internal typealias BuilderClosure = (Query) -> ()

    convenience init(buildClosure: BuilderClosure) {
        self.init()
        buildClosure(self)
    }
    
    convenience init(service: String, account: String) {
        self.init()
        payload[kSecReturnData as String] = kCFBooleanTrue as! Bool
        payload[kSecMatchLimit as String] = kSecMatchLimitOne as String
        payload[kSecAttrAccount as String] = account
        payload[kSecAttrService as String] = service
    }
    
    private init() {
        payload[kSecClass as String] = kSecClassGenericPassword as String
    }
    
    // MARK: - Query properties
    
    var account: String? {
        get { return payload[Security.account] as? String }
        set { payload[Security.account] = newValue }
    }
    
    var service: String? {
        get { return payload[Security.service] as? String }
        set { payload[Security.service] = newValue }
    }
    
    var label: String? {
        get { return payload[Security.label] as? String }
        set { payload[Security.label] = newValue }
    }
    
    var data: Data? {
        get { return payload[Security.data] as? Data }
        set { payload[Security.data] = newValue }
    }
    
    subscript(key: String) -> Any? {
        get { return payload[key] }
        set { payload[key] = newValue }
    }
    
    // MARK: - Keychain Query methods
    var save: Bool {
        _ = self.delete
        let status = SecItemAdd(self.dictionary, nil)
        return status == noErr
    }
    
    var load: Data? {
        let dataTypeRef = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let status = SecItemCopyMatching(self.dictionary, dataTypeRef)
        
        guard status == noErr, let data = dataTypeRef.pointee as? Data else {
            return nil
        }
        
        return data
    }
    
    var delete: Bool {
        return SecItemDelete(self.dictionary) == noErr
    }
    
    class var clear: Bool {
        let dictionary = [kSecClass as String : kSecClassGenericPassword as Any]
        return SecItemDelete(dictionary as CFDictionary) == noErr
    }
}

private extension Query {
    var dictionary: CFDictionary {
        return payload as CFDictionary
    }
}
