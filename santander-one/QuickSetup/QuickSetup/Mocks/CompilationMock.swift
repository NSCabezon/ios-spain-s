import CoreFoundationLib
import SANLegacyLibrary

public final class CompilationMock: CompilationProtocol {
    public var salesForceEndPoint: String = ""
    public var isValidatingCertificate: Bool = false
    public var isTrustInvalidCertificateEnabled: Bool = false
    public var isEnvironmentsAvailable: Bool = false
    public var debugLoginSetup: LoginDebugSetup? = nil
    public var keychain: CompilationKeychainProtocol {
        return CompilationKeychainMock(account: CompilationAccountMock())
    }
    public var userDefaults: CompilationUserDefaultsProtocol {
        fatalError()
    }
    public var defaultDemoUser: String? = ""
    public var defaultMagic: String? = ""
    public var tealiumTarget: String = ""
    public var twinPushSubdomain: String = ""
    public var twinPushAppId: String = ""
    public var twinPushApiKey: String = ""
    public var isLogEnabled: Bool = false
    public var appCenterIdentifier: String = ""
    public var isLoadPfmEnabled: Bool = false
    public var isWebViewTrustInvalidCertificate: Bool = false
    public var managerWallProductionEnvironment: Bool = false
    public var appGroupsIdentifier: String = ""
    public var bsanHostProvider: BSANHostProviderProtocol {
        fatalError()
    }
    public var publicFilesHostProvider: PublicFilesHostProviderProtocol {
        fatalError()
    }
    public var quickbalance: String = ""
    public var service: String = ""
    public var sharedTokenAccessGroup: String = ""
    
    public init() {
        
    }
}

