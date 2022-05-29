import RetailLegacy
import ESCommons
import SANLibraryV3
import CoreFoundationLib

struct Compilation {
    
    let hostModule = HostModule()
    
    struct Keychain {
        
        struct Account {
            static let touchId = DomainConstant.touchIdAccountIdentifier
            static let biometryEvaluationSecurity = DomainConstant.biometryEvaluationSecurityAccountIdentifier
            static let widget = DomainConstant.widgetAccountIdentifier
            static let tokenPush = DomainConstant.tokenPushIdentifier
            static let deviceId = SPDomainConstant.deviceIdIdentifier
            static var old: String?
        }
        
        static let service = CompilationKeychain().service
        static let sharedTokenAccessGroup = XCConfig["SHARED_KEYCHAIN_IDENTIFIER"] ?? ""
    }
    
    struct UserDefaults {
        struct Key {
            static let oldDeviceId: String? = nil
            static let firstOpen: String = "com.ciber-es.retail.first-installation"
        }
    }
    
    static let appGroupsIdentifier = XCConfig["APP_GROUPS_IDENTIFIER"] ?? ""
}
