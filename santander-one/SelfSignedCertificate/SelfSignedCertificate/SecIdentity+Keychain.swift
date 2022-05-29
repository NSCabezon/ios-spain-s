//
//  SecIdentity+Keychain.swift
//  PLSelfSignedCertificate
//
//  Created by crodrigueza on 14/10/21.
//

import Foundation
import os

public enum SelfSignedCertificateSecIdentityError: Error {
    case createSecIdentityError
    case updateSecIdentityError
    case deleteSecIdentityError
    case encodeSecCertificateError
    case getSecCertificateError
    case getPrivateKeyError
    case getPublicKeyError
}

extension SecIdentity {
    
    public static func createSecIdentity(subjectCommonName: String, subjectOrganizationName: String, contryName: String) throws -> SecIdentity {
        guard let secIdentity = SecIdentity.create(ofSize: 2048, subjectCommonName: subjectCommonName, subjectOrganizationName: subjectOrganizationName, contryName: contryName) else {
            os_log("❌ [SecIdentity+Keychain] Error creating identity", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.createSecIdentityError
        }
        
        return secIdentity
    }
    
    @discardableResult public static func updateSecIdentity(secIdentity: SecIdentity, label: String) throws -> Bool {
        if SecIdentity.getSecIdentity(label: label) != nil {
            try SecIdentity.deleteSecIdentity(label: label)
        }
        let query = [kSecValueRef as String: secIdentity]
        let attrsToUpdate = [kSecAttrLabel as String: label]
        let status = SecItemUpdate(query as CFDictionary, attrsToUpdate as CFDictionary)
        guard status == errSecSuccess else {
            os_log("❌ [SecIdentity+Keychain] Error updating identity storage in keychain", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.updateSecIdentityError
        }
        
        return true
    }
    
    public static func getSecIdentity(label: String) -> SecIdentity? {
        let getquery: [String: Any] = [kSecClass as String: kSecClassIdentity,
                                       kSecAttrLabel as String: label,
                                       kSecAttrKeyClass as String: kSecAttrKeyClassPrivate as String,
                                       kSecReturnRef as String: kCFBooleanTrue!]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            os_log("❌ [SecIdentity+Keychain] Error getting identity from keychain", log: .default, type: .error)
            return nil
        }
        let secIdentity = item as! SecIdentity
        
        return secIdentity
    }
    
    @discardableResult public static func deleteSecIdentity(label: String) throws -> Bool {
        let deletequery: [String: Any] = [kSecClass as String: kSecClassIdentity,
                                          kSecAttrLabel as String: label]
        let status = SecItemDelete(deletequery as CFDictionary)
        guard status == errSecSuccess else {
            os_log("❌ [SecIdentity+Keychain] Error deleting identity from keychain", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.deleteSecIdentityError
        }
        
        return true
    }
    
    public static func getSecCertificateFromSecIdentity(secIdentity: SecIdentity?) throws -> SecCertificate {
        guard let secCertificate = secIdentity?.certificate else {
            os_log("❌ [SecIdentity+Keychain] Error getting certificate from identity", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.getSecCertificateError
        }
        
        return secCertificate
    }
    
    public static func encodeCertificate(secCertificate: SecCertificate?) throws -> String {
        guard let certificateString = secCertificate?.data.base64EncodedString() else {
            os_log("❌ [SecIdentity+Keychain] Error encoding certificate", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.encodeSecCertificateError
        }
        
        return certificateString
    }
    
    public static func getPrivateKeyFromSecIdentity(secIdentity: SecIdentity?) throws -> SecKey {
        guard let privateKey = secIdentity?.privateKey else {
            os_log("❌ [SecIdentity+Keychain] Error getting private key from identity", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.getPrivateKeyError
        }
        
        return privateKey
    }
    
    public static func getPublicKeyFromSecIdentity(secIdentity: SecIdentity?) throws -> SecKey {
        guard let publicKey = secIdentity?.certificate?.publicKey else {
            os_log("❌ [SecIdentity+Keychain] Error getting public key from identity", log: .default, type: .error)
            throw SelfSignedCertificateSecIdentityError.getPublicKeyError
        }
        
        return publicKey
    }
}
