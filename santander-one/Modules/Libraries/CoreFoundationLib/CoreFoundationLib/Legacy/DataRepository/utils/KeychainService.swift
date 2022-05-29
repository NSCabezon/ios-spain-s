import Foundation

public protocol KeychainService: AnyObject {
    var account: String { get }
    var service: String { get }
    var accessGroupName: String? { get }
}

fileprivate struct KeychainServiceConstants {
    let kSecClassValue = NSString(format: kSecClass)
    let kSecAttrAccessGroupValue = NSString(format: kSecAttrAccessGroup)
    let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    let kSecValueDataValue = NSString(format: kSecValueData)
    let kSecClassGenericMagicValue = NSString(format: kSecClassGenericPassword)
    let kSecAttrServiceValue = NSString(format: kSecAttrService)
    let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    let kSecReturnDataValue = NSString(format: kSecReturnData)
    let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
    let kSecAttrAccessibleFirstUnlockValue = NSString(format: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
}

extension KeychainService {
    
    func updateMagic(data: String) throws {
        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let constants = KeychainServiceConstants()
            // Instantiate a new default keychain query
            let keychainQuery = NSMutableDictionary(objects:[
                                                        constants.kSecClassGenericMagicValue,
                                                        service,
                                                        account],
                                                    forKeys: [
                                                        constants.kSecClassValue,
                                                        constants.kSecAttrServiceValue,
                                                        constants.kSecAttrAccountValue])
            
            if let accessGroupName = accessGroupName {
                keychainQuery.setValue(accessGroupName, forKey: constants.kSecAttrAccessGroupValue as String)
            }
            // Add new value to KeyChain
            let attributes: [String: AnyObject] = [constants.kSecAttrAccessibleFirstUnlockValue as String: constants.kSecAttrAccessibleValue as AnyObject]
            // Update keychain
            let status = SecItemUpdate(keychainQuery as CFDictionary, attributes as CFDictionary)
            guard
                status != errSecItemNotFound,
                status == errSecSuccess
            else {
                throw IOException()
            }
        }
    }
    
    func removeMagic() throws {
        let constants = KeychainServiceConstants()
        // Instantiate a new default keychain query
        let keychainQuery = NSMutableDictionary(objects: [
                                                    constants.kSecClassGenericMagicValue,
                                                    service,
                                                    account,
                                                    true],
                                                forKeys: [
                                                    constants.kSecClassValue,
                                                    constants.kSecAttrServiceValue,
                                                    constants.kSecAttrAccountValue,
                                                    constants.kSecReturnDataValue])
        
        if let accessGroupName = accessGroupName {
            keychainQuery.setValue(accessGroupName, forKey: constants.kSecAttrAccessGroupValue as String)
        }
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            throw IOException()
        }
    }
    
    func saveMagic(data: String) throws {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let constants = KeychainServiceConstants()
            // Instantiate a new default keychain query
            let keychainQuery = NSMutableDictionary(objects: [
                                                        constants.kSecClassGenericMagicValue,
                                                        service,
                                                        account,
                                                        dataFromString,
                                                        constants.kSecAttrAccessibleFirstUnlockValue],
                                                    forKeys: [
                                                        constants.kSecClassValue,
                                                        constants.kSecAttrServiceValue,
                                                        constants.kSecAttrAccountValue,
                                                        constants.kSecValueDataValue,
                                                        constants.kSecAttrAccessibleValue])
            if let accessGroupName = accessGroupName {
                keychainQuery.setValue(accessGroupName, forKey: constants.kSecAttrAccessGroupValue as String)
            }
            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            if (status != errSecSuccess) {// Always check the status
                throw IOException()
            }
        }
    }
    
    func loadMagic() throws -> String? {
        let constants = KeychainServiceConstants()
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery = NSMutableDictionary(objects: [
                                                    constants.kSecClassGenericMagicValue,
                                                    service,
                                                    account,
                                                    true,
                                                    constants.kSecMatchLimitOneValue,
                                                    constants.kSecAttrAccessibleFirstUnlockValue],
                                                forKeys: [
                                                    constants.kSecClassValue,
                                                    constants.kSecAttrServiceValue,
                                                    constants.kSecAttrAccountValue,
                                                    constants.kSecReturnDataValue,
                                                    constants.kSecMatchLimitValue,
                                                    constants.kSecAttrAccessibleValue])
        if let accessGroupName = accessGroupName {
            keychainQuery.setValue(accessGroupName, forKey: constants.kSecAttrAccessGroupValue as String)
        }
        var dataTypeRef: AnyObject?
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            return try loadOldMagic()
        }
        return contentsOfKeychain
    }

    func loadOldMagic() throws -> String? {
        let constants = KeychainServiceConstants()
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery = NSMutableDictionary(objects: [
                                                    constants.kSecClassGenericMagicValue,
                                                    service,
                                                    account,
                                                    true,
                                                    constants.kSecMatchLimitOneValue],
                                                forKeys: [
                                                    constants.kSecClassValue,
                                                    constants.kSecAttrServiceValue,
                                                    constants.kSecAttrAccountValue,
                                                    constants.kSecReturnDataValue,
                                                    constants.kSecMatchLimitValue])
        if let accessGroupName = accessGroupName {
            keychainQuery.setValue(accessGroupName, forKey: constants.kSecAttrAccessGroupValue as String)
        }
        var dataTypeRef: AnyObject?
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
                do {
                    let id = UUID().uuidString
                    try removeMagic()
                    try saveMagic(data: contentsOfKeychain ?? id)
                } catch {
                    print("Nothing was updated from the keychain. Status code \(error)")
                }
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return contentsOfKeychain
    }
}
