//
//  SantanderKeyTransparentRegisterUseCase.swift
//  RetailLegacy
//
//  Created by Ali Ghanbari Dolatshahi on 10/3/22.
//

import Foundation
import OpenCombine
import CoreDomain
import SANSpainLibrary
import CoreFoundationLib
import SwiftyRSA
import ESCommons

public protocol SantanderKeyTransparentRegisterUseCase {
    func completeTransparentRegister() -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error>
}

struct DefaultSantanderKeyTransparentRegisterUseCase {
    private var repository: SantanderKeyOnboardingRepository
    private var compilation: SpainCompilationProtocol
    
    init(dependencies: SKExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.compilation = dependencies.resolve()
    }
}

extension DefaultSantanderKeyTransparentRegisterUseCase: SantanderKeyTransparentRegisterUseCase {
    
    func completeTransparentRegister() -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error> {
        guard let tokenPush = getTokenPush(),
              let deviceId = getDeviceId(),
              let keys = generateAndStoreRSAKeys()
        else {
            return Fail(error: RepositoryError.unknown).eraseToAnyPublisher()
        }
        let privateKey = keys.privateKey
        let publicKey = keys.publicKey
        
        return repository.automaticRegisterReactive(deviceId: deviceId,
                                                    tokenPush: tokenPush,
                                                    publicKey: publicKey,
                                                    signature: createSignature(deviceId: deviceId,
                                                                               tokenPush: tokenPush,
                                                                               publicKey: publicKey,
                                                                               privateKey: privateKey) ?? "").eraseToAnyPublisher()
    }
}

private extension DefaultSantanderKeyTransparentRegisterUseCase {
    func getTokenPush() -> String? {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        if let tokenPush = try? KeychainWrapper().fetch(query: lookupQuery) as? Data {
            return tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        }

        return nil
    }
    
    func getDeviceId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                        account: compilation.keychainSantanderKey.deviceId,
                                        accessGroup: compilation.sharedTokenAccessGroup)
        if let deviceId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return deviceId
        }

        return nil
    }
    
    func generateAndStoreRSAKeys() -> (privateKey: PrivateKey, publicKey: String)? {
        
        guard let keyPair = try? SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048),
              let publicKey = try? keyPair.publicKey.base64String(),
              let privateKeyData = try? keyPair.privateKey.data()
        else {
            return nil
        }
        let privateKey = keyPair.privateKey
        // NOTE. private key is stored as Data in Keychain and must be converted via PrivateKey(data: keychainData) after retrieved
        guard let publicKeyWithHeader = try? keyPair.publicKey.data().prependx509Header().base64EncodedString() else { return nil }
        let queryPrivate = KeychainQuery(service: compilation.service,
                                         account: compilation.keychainSantanderKey.RSAPrivateKey,
                                         accessGroup: compilation.sharedTokenAccessGroup,
                                         data: privateKeyData as NSCoding)
        let queryPublic = KeychainQuery(service: compilation.service,
                                         account: compilation.keychainSantanderKey.RSAPublicKey,
                                         accessGroup: compilation.sharedTokenAccessGroup,
                                         data: publicKey as NSCoding)
        do {
            try KeychainWrapper().save(query: queryPrivate)
            try KeychainWrapper().save(query: queryPublic)
            return (privateKey: privateKey, publicKey: publicKeyWithHeader)
        } catch {
            return nil
        }
    }
    
    func createSignature(deviceId: String, tokenPush: String, publicKey: String, privateKey: PrivateKey) -> String? {
        let value1 = Int64(Date().timeIntervalSince1970 * 1000)
        var value2 = "NOT_USED"
        let value3 = "sha256withrsa"
        let jsonDict = "{\"tokenPush\":\"\(tokenPush)\",\"publicKey\":\"\(publicKey)\",\"deviceId\":\"\(deviceId)\"}"
        let body = jsonDict.data(using: .utf8)!
        if let value4 = cleanStringWithBase64Encoding(data: body) {
            let values = "\(value1)#\(value2)#\(value3)#\(value4)"
            if let seed = try? ClearMessage(string: values, using: .utf8),
               let signed = try? seed.signed(with: privateKey, digestType: .sha256).base64String
            {
                return "\(values)#\(signed)".getEncodeString()
            }
        }
        return nil
    }

    func cleanStringWithBase64Encoding(data: Data) -> String? {
        String(data: data, encoding: .utf8)?
            .replacingOccurrences(of: "\\/", with: "/")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .getEncodeString()
    }
}
