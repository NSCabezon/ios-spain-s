import CoreFoundationLib
import LoginCommon

struct Compilation {
    let hostModule = HostModule()
}

struct CompilationKeychain: CompilationKeychainProtocol {
    var account: CompilationAccountProtocol {
        return CompilationAccount()
    }
    var service: String {
        return "INTERN_Santander"
    }
    var sharedTokenAccessGroup: String {
        return CommonConstants.development.sharedKeychainIdentifier
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
        return nil
    }
}

struct CompilationUserDefaults: CompilationUserDefaultsProtocol {
    var key: CompilationKeyProtocol {
        return CompilationKey()
    }
}

struct CompilationKey: CompilationKeyProtocol {
    var oldDeviceId: String? {
        return nil
    }
    var firstOpen: String {
        return "com.ciber-es.retail.first-installation"
    }
}

struct TealiumCompilation: TealiumCompilationProtocol {
    let clientKey: String = "cod_cliente"
    let clientIdUpperCased: Bool = false
    let profile: String = "mobileapps"
    let account = "santander"
    let appName = "Santander Retail"
}

struct LoginModuleCoordinatorMock: LoginModuleCoordinatorProtocol {
    var navigationController: UINavigationController?
    
    func start(_ section: LoginSection) {
        
    }
}
