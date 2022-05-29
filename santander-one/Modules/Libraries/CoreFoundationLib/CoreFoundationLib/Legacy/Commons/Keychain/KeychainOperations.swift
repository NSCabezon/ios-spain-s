import Foundation

internal enum KeychainErrors: Error {
    case keychainCreatingError
    case operationError
    case itemNotFoundError
}

final class KeychainOperations: NSObject {
    
    static func exist(query: KeychainQuery) throws -> Bool {
        let attributes = query.unwrappedDictionary(extraFields:
                                                    [kSecReturnData: false])
        let status = SecItemCopyMatching(attributes as NSDictionary,
                                         nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainErrors.keychainCreatingError
        }
    }
    
    static func isSynchronizationAvailable() -> Bool {
        #if TARGET_OS_IPHONE
        return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1
        #else
        return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_8_4
        #endif
    }
    
    static func add(query: KeychainQuery) throws {
        let attributes = query.unwrappedDictionary(extraFields:
                                                    [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock])
        let status = SecItemAdd(attributes as NSDictionary,
                                nil)
        try KeychainOperations.defaultStatusManage(status)
    }
    
    static func update(query: KeychainQuery) throws {
        let attributes = query.unwrappedDictionary()
        guard let archivedData = query.archivedData else { throw KeychainErrors.operationError }
        let dataToUpdate: [AnyHashable: Any] = [kSecValueData: archivedData]
        let status = SecItemUpdate(attributes as NSDictionary,
                                   dataToUpdate as NSDictionary)
        try KeychainOperations.defaultStatusManage(status)
    }
    
    static func get(query: KeychainQuery) throws -> Data? {
        let attributes = query.unwrappedDictionary(extraFields:
                                                    [kSecReturnData: true])
        var result: AnyObject?
        let status = SecItemCopyMatching(attributes as NSDictionary,
                                         &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            throw KeychainErrors.itemNotFoundError
        default:
            throw KeychainErrors.operationError
        }
    }
    
    static func remove(query: KeychainQuery) throws {
        let attributes = query.unwrappedDictionary()
        let status = SecItemDelete(attributes as NSDictionary)
        try KeychainOperations.defaultStatusManage(status)
    }
}

private extension KeychainOperations {
    static var defaultStatusManage: (OSStatus) throws -> Void = { status in
        switch status {
        case errSecSuccess:
            break
        case errSecItemNotFound:
            throw KeychainErrors.itemNotFoundError
        default:
            throw KeychainErrors.operationError
        }
    }
}
