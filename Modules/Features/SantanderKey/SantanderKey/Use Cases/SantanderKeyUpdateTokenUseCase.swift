//
//  SantanderKeyUpdateTokenUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 22/4/22.
//

import OpenCombine
import CoreDomain
import SANSpainLibrary
import SwiftyRSA
import CoreFoundationLib
import SANLegacyLibrary
import Foundation
import ESCommons

public struct DeviceInfoPush {
    var deviceCode: String
    var deviceModel: String
    var appVersion: String
    var sdkVersion: String
    var soVersion: String
    var deviceUDID: String
    var deviceID: String
}

public protocol SantanderKeyUpdateTokenUseCase {
    func updateTokenPush() -> AnyPublisher<Void, Error>
}

public protocol SantanderKeyUpdateTokenUseCaseProtocol: UseCase<Void, Void, StringErrorOutput> {}


public class DefaultSantanderKeyUpdateTokenUseCase: UseCase<Void, Void, StringErrorOutput> {
    private var repository: SantanderKeyOnboardingRepository
    private var compilation: SpainCompilationProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let notificationDeviceInfoProvider: NotificationDeviceInfoProvider

    public init(dependencies: DependenciesResolver) {
        self.repository = dependencies.resolve()
        self.compilation = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
        self.notificationDeviceInfoProvider = dependencies.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let tokenPush = getTokenPush(),
              let keys = generateAndStoreRSAKeys(),
              let sanKeyId = getSanKeyId()
        else {
            return .error(StringErrorOutput("SantanderKeyUpdateTokenUseCase error"))
        }
        let privateKey = keys.privateKey
        let publicKey = keys.publicKey
        var deviceInfo = getDeviceInfo()
        let input = getUpdateInput(tokenPush: tokenPush, deviceInfo: deviceInfo)
        guard let status = try? repository.updateTokenPush(input: input, signature: createSignature(input: input, sanKeyId: sanKeyId, privateKey: privateKey) ?? "") else {
            return .error(StringErrorOutput("SantanderKeyUpdateTokenUseCase error"))
        }
        return .ok(())
    }
}

extension DefaultSantanderKeyUpdateTokenUseCase: SantanderKeyUpdateTokenUseCaseProtocol {}

extension DefaultSantanderKeyUpdateTokenUseCase: SantanderKeyUpdateTokenUseCase {
    public func updateTokenPush() -> AnyPublisher<Void, Error> {
        guard let tokenPush = getTokenPush(),
              let keys = generateAndStoreRSAKeys(),
              let sanKeyId = getSanKeyId()
        else {
            return Fail(error: RepositoryError.unknown).eraseToAnyPublisher()
        }
        let privateKey = keys.privateKey
        let publicKey = keys.publicKey
        var deviceInfo = getDeviceInfo()
        let input = getUpdateInput(tokenPush: tokenPush, deviceInfo: deviceInfo)
        return repository.updateTokenPushReactive(input: input, signature: createSignature(input: input, sanKeyId: sanKeyId, privateKey: privateKey) ?? "").eraseToAnyPublisher()
    }
}

private extension DefaultSantanderKeyUpdateTokenUseCase {
    func getTokenPush() -> String? {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        if let tokenPush = try? KeychainWrapper().fetch(query: lookupQuery) as? Data {
            return tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        }

        return nil
    }
    
    func getSanKeyId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                                account: compilation.keychainSantanderKey.sankeyId,
                                                accessGroup: compilation.sharedTokenAccessGroup)
        if let sanKeyId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return sanKeyId
        }
        
        return nil
    }
    
    func getDeviceInfo() -> DeviceInfoPush {
        let deviceCode = UIDevice.current.machineName
        let deviceModel = UIDevice.current.model
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let sdkVersion = notificationDeviceInfoProvider.getVersionNumber()
        let iOSVersion = UIDevice.current.systemVersion
        let deviceUDID = notificationDeviceInfoProvider.getDeviceUDID()
        let deviceID = getDeviceId()
        
        return DeviceInfoPush(deviceCode: deviceCode, deviceModel: deviceModel, appVersion: appVersion, sdkVersion: sdkVersion ?? "", soVersion: iOSVersion, deviceUDID: deviceUDID ?? "", deviceID: deviceID ?? "")
    }
    
    private func getDeviceId() -> String? {
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
        guard let publicKeyWithHeader = try? keyPair.publicKey.data().prependx509Header().base64EncodedString() else { return nil }

        // NOTE. private key is stored as Data in Keychain and must be converted via PrivateKey(data: keychainData) after retrieved
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
    
    func createSignature(input: SantanderKeyUpdateTokenPushInput, sanKeyId: String, privateKey: PrivateKey) -> String? {
        let value1 = Int64(Date().timeIntervalSince1970 * 1000)
        var value2 = sanKeyId
        let value3 = "sha256withrsa"
        let candidateData = try? JSONEncoder().encode(input)
        if let value4 = cleanStringWithBase64Encoding(data: candidateData!) {
            let values = "\(value1)#\(value2)#\(value3)#\(value4)"
            if let seed = try? ClearMessage(string: values, using: .utf8),
               let signed = try? seed.signed(with: privateKey, digestType: .sha256).base64String {
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
    
    func getUpdateInput(tokenPush: String, deviceInfo: DeviceInfoPush) -> SantanderKeyUpdateTokenPushInput {
        return SantanderKeyUpdateTokenPushInput(deviceId: deviceInfo.deviceID, udid: deviceInfo.deviceUDID, tokenPush: tokenPush, deviceCode: deviceInfo.deviceCode, deviceModel: deviceInfo.deviceModel, deviceFabric: "Apple", appVersion: deviceInfo.appVersion, sdkVersion: deviceInfo.sdkVersion, soVersion: deviceInfo.soVersion, devicePlatform: "ios")
    }
}
