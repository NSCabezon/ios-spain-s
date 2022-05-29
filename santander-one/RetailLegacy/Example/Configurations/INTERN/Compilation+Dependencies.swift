import CoreFoundationLib
import RetailLegacy
import SANLegacyLibrary

extension Compilation: CompilationProtocol {
    var debugLoginSetup: LoginDebugSetup? {
        return LoginDebugSetup(defaultUser: defaultDemoUser, defaultMagic: defaultMagic)
    }
    var quickbalance: String {
        return keychain.account.widget
    }
    var service: String {
        return keychain.service
    }
    var sharedTokenAccessGroup: String {
        return keychain.sharedTokenAccessGroup
    }
    var bsanHostProvider: BSANHostProviderProtocol {
        return hostModule.providesBSANHostProvider()
    }
    var publicFilesHostProvider: PublicFilesHostProviderProtocol {
        return hostModule.providesPublicFilesHostProvider()
    }
    var keychain: CompilationKeychainProtocol {
        return CompilationKeychain()
    }
    var userDefaults: CompilationUserDefaultsProtocol {
        return CompilationUserDefaults()
    }
    var defaultDemoUser: String? {
        return "12345678Z"
    }
    var defaultMagic: String? {
        return "14725836"
    }
    var tealiumTarget: String {
        return "dev"
    }
    var twinPushSubdomain: String {
        return "santander"
    }
    var twinPushAppId: String {
        return ""
    }
    var twinPushApiKey: String {
        return ""
    }
    var salesForceAppId: String {
        return "CLlb9eKqlm9naNL1kF+5GaAAek2h5eSfs3iZQI2zR8OCz3H7viGgFW6grY9QBkNe"
    }
    var salesForceAccessToken: String {
        return "6zK2qQ2qkcWSm3kNNYFRPX8eFvxTA740Sv6A5ckY5D4="
    }
    var salesForceMid: String {
        return "NVMX4RCNDARAJZmuOAcccw=="
    }
    var emmaApiKey: String {
        return "santanderdevpTz6MgP3b"
    }
    var isLogEnabled: Bool {
        return true
    }
    var isEnvironmentsAvailable: Bool {
        return true
    }
    var isValidatingCertificate: Bool {
        return false
    }
    var appCenterIdentifier: String {
        return "c7e927f9-4e36-4f17-b49c-578154909ffd"
    }
    var isLoadPfmEnabled: Bool {
        return true
    }
    var isWebViewTrustInvalidCertificate: Bool {
        return true
    }
    var managerWallProductionEnvironment: Bool {
        return false
    }
    var appGroupsIdentifier: String {
        return CommonConstants.development.appGroupsIdentifier
    }
    var isTrustInvalidCertificateEnabled: Bool {
        return true
    }
}

