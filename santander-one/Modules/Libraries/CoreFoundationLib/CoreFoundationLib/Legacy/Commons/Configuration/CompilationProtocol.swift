import SANLegacyLibrary

public protocol CompilationProtocol {
    var service: String { get }
    var sharedTokenAccessGroup: String { get }
    var isEnvironmentsAvailable: Bool { get }
    var debugLoginSetup: LoginDebugSetup? { get }
    
    var keychain: CompilationKeychainProtocol { get }
    var userDefaults: CompilationUserDefaultsProtocol { get }
        
    var defaultDemoUser: String? { get }
    var defaultMagic: String? { get }
    var tealiumTarget: String { get }

    var isLogEnabled: Bool { get }
    var appCenterIdentifier: String { get }
    var isLoadPfmEnabled: Bool { get }
    var isTrustInvalidCertificateEnabled: Bool { get }
    var managerWallProductionEnvironment: Bool { get }
    var appGroupsIdentifier: String { get }
    
    var bsanHostProvider: BSANHostProviderProtocol { get }
    var publicFilesHostProvider: PublicFilesHostProviderProtocol { get }
    var twinPushSubdomain: String { get }
    var twinPushAppId: String { get }
    var twinPushApiKey: String { get }
}

public protocol PublicFilesHostProviderProtocol {
    var publicFilesEnvironments: [PublicFilesEnvironmentDTO] { get }
}

public protocol CompilationKeychainProtocol {
    var account: CompilationAccountProtocol { get }
    var service: String { get }
    var sharedTokenAccessGroup: String { get }
}

public protocol CompilationAccountProtocol {
    var touchId: String { get }
    var biometryEvaluationSecurity: String { get }
    var widget: String { get }
    var tokenPush: String { get }
    var old: String? { get }
}

public protocol CompilationUserDefaultsProtocol {
    var key: CompilationKeyProtocol { get }
}

public protocol CompilationKeyProtocol {
    var oldDeviceId: String? { get }
    var firstOpen: String { get }
}
