import CoreFoundationLib
import ESCommons
import RetailLegacy
import SANLegacyLibrary 

extension Compilation {

    static var bsanHostProvider: BSANHostProviderProtocol {
        return HostModule().providesBSANHostProvider()
    }
    static var publicFilesHostProvider: PublicFilesHostProviderProtocol {
        return HostModule().providesPublicFilesHostProvider()
    }
}

extension Compilation: SpainCompilationProtocol {
    var debugLoginSetup: LoginDebugSetup? {
        guard defaultDemoUser?.isEmpty == false && defaultMagic?.isEmpty == false else { return nil }
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
    var keychainSantanderKey: CompilationSantanderKeyProtocol {
        return CompilationSantanderKey()
    }
    var userDefaults: CompilationUserDefaultsProtocol {
        return CompilationUserDefaults()
    }
    var defaultDemoUser: String? {
        return XCConfig["DEFAULT_DEMO_USER"]
    }
    var defaultMagic: String? {
        return XCConfig["DEFAULT_MAGIC"]
    }
    var isEnvironmentsAvailable: Bool {
        return XCConfig["ENVIRONMENTS_AVAILABLE"] ?? false
    }
    var tealiumTarget: String {
        return XCConfig["TEALIUM_TARGET"] ?? ""
    }
    var twinPushSubdomain: String {
        return XCConfig["TWIN_PUSH_SUBDOMAIN"] ?? ""
    }
    var twinPushAppId: String {
        return XCConfig["TWIN_PUSH_APP_ID"] ?? ""
    }
    var twinPushApiKey: String {
        return XCConfig["TWIN_PUSH_API_KEY"] ?? ""
    }
    var salesForceAppId: String {
        return XCConfig["SALES_FORCE_APP_ID"] ?? ""
    }
    var salesForceAccessToken: String {
        return XCConfig["SALES_FORCE_ACCESS_TOKEN"] ?? ""
    }
    var salesForceMid: String {
        return XCConfig["SALES_FORCE_MID"] ?? ""
    }
    var salesForceEndPoint: String {
        return XCConfig["SALES_FORCE_END_POINT"] ?? ""
    }
    var emmaApiKey: String {
        return XCConfig["EMMA_API_KEY"] ?? ""
    }
    var isLogEnabled: Bool {
        return XCConfig["LOG_ENABLED"] ?? false
    }
    var appCenterIdentifier: String {
        return XCConfig["APP_CENTER_IDENTIFIER"] ?? ""
    }
    var isLoadPfmEnabled: Bool {
        return XCConfig["LOAD_PFM_ENABLED"] ?? false
    }
    var isTrustInvalidCertificateEnabled: Bool {
        return XCConfig["TRUST_INVALID_CERTIFICATE"] ?? false
    }
    var managerWallProductionEnvironment: Bool {
        return XCConfig["MANAGER_WALL_PRODUCTION_ENVIRONMENT"] ?? false
    }
    var appGroupsIdentifier: String {
        return XCConfig["APP_GROUPS_IDENTIFIER"] ?? ""
    }
}

struct CompilationKeychain: CompilationKeychainProtocol {    
    var account: CompilationAccountProtocol {
        return CompilationAccount()
    }
    var service: String {
        return XCConfig["KEYCHAIN_SERVICE"] ?? ""
    }
    var sharedTokenAccessGroup: String {
        return XCConfig["SHARED_KEYCHAIN_IDENTIFIER"] ?? ""
    }
}

struct CompilationAccount: CompilationAccountProtocol {
    var touchId: String {
        DomainConstant.touchIdAccountIdentifier
    }
    var biometryEvaluationSecurity: String {
        DomainConstant.biometryEvaluationSecurityAccountIdentifier
    }
    var widget: String {
        DomainConstant.widgetAccountIdentifier
    }
    var tokenPush: String {
        DomainConstant.tokenPushIdentifier
    }
    var old: String? {
        return Compilation.Keychain.Account.old
    }
}

struct CompilationUserDefaults: CompilationUserDefaultsProtocol {
    var key: CompilationKeyProtocol {
        return CompilationKey()
    }
}

struct CompilationKey: CompilationKeyProtocol {
    var oldDeviceId: String? {
        return Compilation.UserDefaults.Key.oldDeviceId
    }
    var firstOpen: String {
        return Compilation.UserDefaults.Key.firstOpen
    }
}

struct CompilationSantanderKey: CompilationSantanderKeyProtocol {
    var deviceId: String {
        return SPDomainConstant.deviceIdIdentifier
    }
    var RSAPrivateKey: String {
        return SPDomainConstant.RSAPrivateKey
    }
    var RSAPublicKey: String {
        return SPDomainConstant.RSAPublicKey
    }
    var sankeyId: String {
        return SPDomainConstant.santanderKeyIdentifier
    }
}
