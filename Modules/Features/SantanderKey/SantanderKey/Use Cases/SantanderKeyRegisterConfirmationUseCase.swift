//
//  SantanderKeyRegisterConfirmationUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 10/3/22.
//

import OpenCombine
import CoreDomain
import SANSpainLibrary
import SwiftyRSA
import CoreFoundationLib
import SANLegacyLibrary
import SANLibraryV3
import ESCommons

public struct DeviceInfo {
    var deviceAlias: String
    var deviceLanguage: String
    var deviceCode: String
    var deviceModel: String
    var appVersion: String
    var sdkVersion: String
    var soVersion: String
    var deviceLatitude: String
    var deviceLongitude: String
    var deviceUDID: String
}

public struct OTPInfo {
    var otpReference: String
    var otpValue: String
    var sanKeyId: String
    var tokenPush: String
}

// extension TrusteerInfoDTO: TrusteerInfoRepresentable {}

public protocol SantanderKeyRegisterConfirmationUseCase {
    func registerConfirmation(otpReference: String, otpValue: String, sanKeyId: String, deviceAlias: String, lat: String, long: String) ->
    AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error>
}

struct DefaultSantanderKeyRegisterConfirmationUseCase {
    private var repository: SantanderKeyOnboardingRepository
    private var compilation: SpainCompilationProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let notificationDeviceInfoProvider: NotificationDeviceInfoProvider
    private let stringLoader: StringLoader

    init(dependencies: SKExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.compilation = dependencies.resolve()
        self.trusteerRepository = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
        self.notificationDeviceInfoProvider = dependencies.resolve()
        self.stringLoader = dependencies.resolve()
    }
}

extension DefaultSantanderKeyRegisterConfirmationUseCase: SantanderKeyRegisterConfirmationUseCase {
    
    func registerConfirmation(otpReference: String, otpValue: String, sanKeyId: String, deviceAlias: String, lat: String, long: String) ->
    AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error> {
        guard let tokenPush = getTokenPush(),
              let keys = generateAndStoreRSAKeys()
        else {
            return Fail(error: SantanderKeyError.genericError()).eraseToAnyPublisher()
        }
        let privateKey = keys.privateKey
        let publicKey = keys.publicKey
        var trusteerInfo = getTrusteerInfo()
        var deviceInfo = getDeviceInfo(deviceAlias: deviceAlias, lat: lat, long: long)
        let otpInfo = OTPInfo(otpReference: otpReference, otpValue: otpValue, sanKeyId: sanKeyId, tokenPush: tokenPush)
        let input = getConfirmationInput(otpInfo: otpInfo, deviceInfo: deviceInfo, privateKey: privateKey, publicKey: publicKey, trusteerInfo: trusteerInfo)
        return repository.registerConfirmationReactive(input: input, signature: createSignature(input: input, sanKeyId: sanKeyId, privateKey: privateKey) ?? "").eraseToAnyPublisher()
    }
}

private extension DefaultSantanderKeyRegisterConfirmationUseCase {
    func getTokenPush() -> String? {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        if let tokenPush = try? KeychainWrapper().fetch(query: lookupQuery) as? Data {
            return tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        }

        return nil
    }
    
    func getDeviceInfo(deviceAlias: String, lat: String, long: String) -> DeviceInfo {
        let alias = deviceAlias
        let deviceLanguage = self.stringLoader.getCurrentLanguage().languageType.languageCode
        let deviceCode = UIDevice.current.machineName
        let deviceModel = UIDevice.current.model
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let sdkVersion = notificationDeviceInfoProvider.getVersionNumber()
        let iOSVersion = UIDevice.current.systemVersion
        let deviceUDID = notificationDeviceInfoProvider.getDeviceUDID()
        
        return DeviceInfo(deviceAlias: alias, deviceLanguage: deviceLanguage, deviceCode: deviceCode, deviceModel: deviceModel, appVersion: appVersion, sdkVersion: sdkVersion ?? "", soVersion: iOSVersion, deviceLatitude: lat, deviceLongitude: long, deviceUDID: deviceUDID ?? "")
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
    
    func createSignature(input: SantanderKeyRegisterConfirmationInput, sanKeyId: String, privateKey: PrivateKey) -> String? {
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
    
    func getTrusteerInfo() -> TrusteerInfoRepresentable? {
        guard let appSessiondId = trusteerRepository.appSessionId,
              appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessiondId, appConfigRepository: appConfigRepository)
    }
    
    func getConfirmationInput(otpInfo: OTPInfo, deviceInfo: DeviceInfo, privateKey: PrivateKey, publicKey: String, trusteerInfo: TrusteerInfoRepresentable?) -> SantanderKeyRegisterConfirmationInput {
        
        var trusteerInfo = SantanderKeyTrusteerInfo(userAgent: trusteerInfo?.userAgent ?? "",
                                                    customerSessionId: trusteerInfo?.customerSessionId ?? "",
                                                    url: "/san-keys/register")
        var geoDevice = SantanderKeyGeolocation(
            longitude: deviceInfo.deviceLongitude,
            latitude: deviceInfo.deviceLatitude
        )
        
        return SantanderKeyRegisterConfirmationInput(otpReference: otpInfo.otpReference, otpValue: otpInfo.otpValue, sanKeyId: otpInfo.sanKeyId, udid: deviceInfo.deviceUDID, publicKey: publicKey, tokenPush: otpInfo.tokenPush, deviceAlias: deviceInfo.deviceAlias, deviceLanguage: deviceInfo.deviceLanguage, deviceCode: deviceInfo.deviceCode, deviceModel: deviceInfo.deviceModel, deviceFabric: "Apple", appVersion: deviceInfo.appVersion, sdkVersion: deviceInfo.sdkVersion, soVersion: deviceInfo.soVersion, devicePlatform: "ios", modUser: "SK", trusteerInfo: trusteerInfo, geoDevice: geoDevice)
    }
}
