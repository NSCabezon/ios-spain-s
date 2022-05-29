import CoreFoundationLib

struct CompilationKeychainMock: CompilationKeychainProtocol {
    var account: CompilationAccountProtocol
    var service: String = "KEYCHAIN_SERVICE"
    var sharedTokenAccessGroup: String = "SHARED_KEYCHAIN_IDENTIFIER"
}

struct CompilationAccountMock: CompilationAccountProtocol {
    var touchId: String = "touchIdData"
    var biometryEvaluationSecurity: String = "biometryEvaluationSecurityAccount"
    var widget: String = "isWidgetEnabled"
    var tokenPush: String = "tokenPushData"
    var old: String? = "retail"
}
