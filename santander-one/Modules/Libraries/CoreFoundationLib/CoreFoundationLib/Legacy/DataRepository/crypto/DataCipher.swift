//
//  DataCipher.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation
import CryptoSwift



public class DataCipher {
    
    private var cipherKey: String = ""
    private let keychainService: KeychainService
    
    public init(keychainService: KeychainService) {
        self.keychainService = keychainService
        initCipherKey()
    }
    
    
    public static func encryptDESde(_ message: String,_ clave32: String) throws -> String {
        return message.encryptWithKey(keyString: clave32)
    }
    
    public static func decryptDESde(_ message: String,_ clave32: String) throws -> String {
        return message.decryptWithKey(keyString: clave32)
    }
    
    public func encryptAES(_ plainText: String) -> String {
        
        var encodeString = ""
        do{
            let aes = try AES(key: cipherKey, iv: cipherKey)
            let encrypted: [UInt8] = try aes.encrypt(Array(plainText.utf8))
            let encryptedNSData = NSData(bytes: encrypted, length: encrypted.count)
            encodeString = encryptedNSData.base64EncodedString(options: [])
        }catch{}
        return encodeString
    }

    public func decryptAES(_ cipherText: String) -> String {
        
        var decryptedBase64 = ""
        do{
            let aes = try AES(key: cipherKey, iv: cipherKey)
            if let data = Data(base64Encoded: cipherText, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
                let decrypted: [UInt8] = try aes.decrypt([UInt8](data))
                if let decryptedString = String(bytes: decrypted, encoding: String.Encoding.utf8) {
                    decryptedBase64 = decryptedString
                }
                
            }
        }catch{}
        return decryptedBase64
    }
    
    public func decryptNotNull( _ cipherTextLocal64: String, isEncrypted: Bool) -> String {
        if isEncrypted {
            return decryptAES(cipherTextLocal64)
        } else {
            return cipherTextLocal64
        }
        
    }
    
    public func decryptNull( _ cipherTextLocal64: String?, isEncrypted: Bool) -> String? {
        if let cipherText = cipherTextLocal64 {
            return decryptNotNull(cipherText, isEncrypted: isEncrypted)
        } else {
            return nil
        }
    }
    
    public func encryptNull( _ cipherTextLocal64: String?) -> String? {
        if let cipherText = cipherTextLocal64 {
            return encryptAES(cipherText)
        } else {
            return nil
        }
    }
    
    public func computeMagic(_ message: [UInt8]) throws -> String {
        let data = Data(message)
        let hash = data.sha256()
        return hash.toHexString()
    }
    
    public func cipherData(_ data: Data?) -> Data? {
        guard let dataToString = data else { return nil }
        let strData = String(decoding: dataToString, as: UTF8.self)
        if let cipherData = encryptNull(strData), !cipherData.isEmpty {
            return Data(cipherData.utf8)
        } else {
            return nil
        }
    }
}

private extension DataCipher {
    
    func initCipherKey() {
        Installation.keychainService = keychainService
        do {
            let installationId = [UInt8] (try Installation.id().utf8)
            self.cipherKey = try self.computeMagic(installationId)
        } catch {
            self.cipherKey = try! Installation.id()
        }
        
        if self.cipherKey.count < 16 {
            self.cipherKey = self.fillWithChar(self.cipherKey, 16, "0")
        } else {
            self.cipherKey = self.cipherKey.substring(0,16)!
        }
    }
    
    func fillWithChar(_ str: String,_  size: Int,_  caracter: String) -> String {
        var temp = ""
        for _ in (0..<size - str.count) {
            temp = temp + caracter
        }
        return str + temp
    }
}
