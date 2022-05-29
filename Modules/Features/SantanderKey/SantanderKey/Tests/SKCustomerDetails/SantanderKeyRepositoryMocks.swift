//
//  SantanderKeyRepositoryMocks.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 19/4/22.
//

import CoreFoundationLib
import SANLegacyLibrary
import OpenCombine
import CoreDomain
import SANSpainLibrary
import ESCommons

struct CompilationMock: CompilationProtocol {
    var service: String = ""
    var sharedTokenAccessGroup: String = ""
    var isEnvironmentsAvailable: Bool = true
    var debugLoginSetup: LoginDebugSetup?
    var keychain: CompilationKeychainProtocol {
        CompilationKeychainMock()
    }
    var userDefaults: CompilationUserDefaultsProtocol {
        fatalError()
    }
    var defaultDemoUser: String? {
        fatalError()
    }
    var defaultMagic: String? {
        fatalError()
    }
    var tealiumTarget: String {
        fatalError()
    }
    var isLogEnabled: Bool {
        fatalError()
    }
    var appCenterIdentifier: String {
        fatalError()
    }
    var isLoadPfmEnabled: Bool {
        fatalError()
    }
    var isTrustInvalidCertificateEnabled: Bool {
        fatalError()
    }
    var managerWallProductionEnvironment: Bool {
        fatalError()
    }
    var appGroupsIdentifier: String {
        fatalError()
    }
    var bsanHostProvider: BSANHostProviderProtocol {
        fatalError()
    }
    var publicFilesHostProvider: PublicFilesHostProviderProtocol {
        fatalError()
    }
    var twinPushSubdomain: String {
        fatalError()
    }
    var twinPushAppId: String {
        fatalError()
    }
    var twinPushApiKey: String {
        fatalError()
    }
}

class LocalAuthenticationPermissionsManagerMock: LocalAuthenticationPermissionsManagerProtocol {
    var biometryTypeAvailable: BiometryTypeEntity {
        fatalError()
    }
    var isTouchIdEnabled: Bool {
        fatalError()
    }
    var deviceToken: String? {
        fatalError()
    }
    var footprint: String? {
        fatalError()
    }
    var biometryData: Data? {
        fatalError()
    }
    func enableBiometric() {
        fatalError()
    }
    func enableBiometric(byKey key: String) -> BiometryEvaluationResultEntity {
        fatalError()
    }
    func evaluateBiometry(reason: String, completion: @escaping (BiometryEvaluationResultEntity) -> Void) {
        fatalError()
    }
    func checkValidBiometry(_ oldDomainState: Data?) -> Bool {
        fatalError()
    }
}

struct SantanderKeyOnboardingRepositoryMock: SantanderKeyOnboardingRepository {
    func getClientStatusReactive(santanderKeyID: String?, deviceId: String?) -> AnyPublisher<SantanderKeyStatusRepresentable, Error> {
        return Future { promise in
            let status = SantanderKeyStatusDTOMock(clientStatus: "0", otherSKinDevice: "true")
            promise(.success(status))
        }.eraseToAnyPublisher()
    }
    func getClientStatus(santanderKeyID: String?, deviceId: String?) throws -> SantanderKeyStatusRepresentable {
        fatalError()
    }
    func automaticRegisterReactive(deviceId: String, tokenPush: String, publicKey: String, signature: String) -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error> {
        fatalError()
    }
    func automaticRegister(deviceId: String, tokenPush: String, publicKey: String, signature: String) throws -> SantanderKeyAutomaticRegisterResultRepresentable {
        fatalError()
    }
    func registerGetAuthMethodReactive() -> AnyPublisher<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error> {
        fatalError()
    }
    func registerGetAuthMethod() throws -> (SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable) {
        fatalError()
    }
    func registerValidationWithPINReactive(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        fatalError()
    }
    func registerValidationWithPIN(sanKeyId: String, cardPan: String, cardType: String, pin: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable) {
        fatalError()
    }
    func registerValidationWithPositionsReactive(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        fatalError()
    }
    func registerValidationWithPositions(sanKeyId: String, positions: String, valuePositions: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable) {
        fatalError()
    }
    func registerConfirmationReactive(input: SantanderKeyRegisterConfirmationInput, signature: String) -> AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error> {
        fatalError()
    }
    func registerConfirmation(input: SantanderKeyRegisterConfirmationInput, signature: String) throws -> SantanderKeyRegisterConfirmationResultRepresentable {
        fatalError()
    }
    func getSantanderKeyDetailReactive(sanKeyId: String?) -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error> {
        return Future { promise in
            let status = SantanderKeyDetailResultDTOMock(sanKeyApp: "", deviceAlias: "", deviceModel: "", creationDate: "", deviceCode: "", deviceManu: "", soVersion: "", devicePlatform: "")
            promise(.success(status))
        }.eraseToAnyPublisher()
    }
    func getSantanderKeyDetail(sanKeyId: String?) throws -> SantanderKeyDetailResultRepresentable {
        fatalError()
    }
}

struct CompilationKeychainMock: CompilationKeychainProtocol {
    var account: CompilationAccountProtocol {
        return CompilationAccountMock()
    }
    var santanderKey: CompilationSantanderKeyProtocol {
        return CompilationSantanderKeyMock()
    }
    var service: String {
        return ""
    }
    var sharedTokenAccessGroup: String {
        return ""
    }
}

struct CompilationAccountMock: CompilationAccountProtocol {
    var touchId: String {
        fatalError()
    }
    var biometryEvaluationSecurity: String {
        fatalError()
    }
    var widget: String {
        fatalError()
    }
    var tokenPush: String {
        fatalError()
    }
    var old: String? {
        fatalError()
    }
}

struct CompilationSantanderKeyMock: CompilationSantanderKeyProtocol {
    var deviceId: String {
        return ""
    }
    var sankeyId: String {
        return ""
    }
    var RSAPrivateKey: String {
        fatalError()
    }
    var RSAPublicKey: String {
        fatalError()
    }
}
