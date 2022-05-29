import Security
import LocalAuthentication
import UIKit.UIDevice
import SAMKeychain
import CoreFoundationLib
import RetailLegacy

class KeychainAuthentication {
    private let compilation = CompilationAdapter.shared
    private let service = Compilation.Keychain.service
    private let account = Compilation.Keychain.Account.biometryEvaluationSecurity
    private let biometricPassword = "biometricIsActive"
    private let keychainPasswordItem: KeychainPasswordItem
    private var context = LAContext()
    private let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    private var _availableType: BiometryType?
    
    var availableType: BiometryType {
        if let type = _availableType {
            return type
        }
        _availableType = findOutBiometryType()
        return self.availableType
    }
    
    init(appEventsNotifier: AppEventsNotifier) {
        keychainPasswordItem = KeychainPasswordItem(service: service, account: account)
        appEventsNotifier.add(subscriptor: self)
    }
    
    func enableBiometric() {
        try? keychainPasswordItem.save(biometricPassword)
    }
    
    func evaluate(reason: String, completion: @escaping (BiometryEvaluationResult) -> Void) {        
        keychainPasswordItem.read(biometricReason: reason) { [weak self] result in
            switch result {
            case .success(let password):
                if password == self?.biometricPassword {
                    completion(.success)
                } else {
                    completion(.evaluationError(error: .unknown))
                }
            case .error(let error):
                switch error {
                case .noPassword:
                    completion(.evaluationError(error: .biometricOutOfDate))
                case .unexpectedItemData, .unexpectedPasswordData:
                    completion(.evaluationError(error: .unknown))
                case .unhandledError(status: let status):
                    switch status {
                    case errSecUserCanceled:
                        completion(.evaluationError(error: .userCancel))
                    default:
                        completion(.evaluationError(error: .systemCancel))
                    }
                }
            }
        }
    }
    
    private func findOutBiometryType() -> BiometryType {
        var error: NSError?
        if context.canEvaluatePolicy(policy, error: &error) {
            if #available(iOS 11, *) {
                switch context.biometryType {
                case .touchID:
                    return .touchId
                case .faceID:
                    return .faceId
                case .none:
                    return .none
                @unknown default:
                    return .none
                }
            } else {
                return .touchId
            }
        }
        var laError: LAError?
        if let error = error {
            laError = LAError(_nsError: error)
        }
        if #available(iOS 11, *) {
            switch context.biometryType {
            case .touchID:
                return .error(biometry: .touchId, error: BiometryError(laError: laError))
            case .faceID:
                return .error(biometry: .faceId, error: BiometryError(laError: laError))
            case .none:
                return .error(biometry: .none, error: BiometryError(laError: laError))
            @unknown default:
                return .none
            }
        }
        let hasNoBiometry = UIDevice.current.hasNoBiometry
        return .error(biometry: hasNoBiometry ? .none: .touchId, error: BiometryError(laError: laError))
    }
           
    var isTouchIdEnabled: Bool {
        guard let touchIdEnabled = SAMKeychainQuery().getTouchIdData(compilation)?.touchIDLoginEnabled else {
            return false
        }
        return touchIdEnabled
    }
    
    var deviceToken: String? {
        return SAMKeychainQuery().getTouchIdData(compilation)?.deviceToken
    }
    
    var footprint: String? {
        return SAMKeychainQuery().getTouchIdData(compilation)?.footprint
    }
}

private struct KeychainPasswordItem {
    
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    enum KeychainReadingResult {
        case success(String)
        case error(KeychainError)
    }
    
    // MARK: - Private attributes
    
    private let service: String
    private(set) var account: String
    
    // MARK: - Public methods
    
    init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    func read(biometricReason: String, completion: @escaping (KeychainReadingResult) -> Void) {
        DispatchQueue.global().async {
            let query = KeychainPasswordItem.keychainReadQuery(withService: self.service, account: self.account, biometricReason: biometricReason)
            var queryResult: AnyObject?
            let status = withUnsafeMutablePointer(to: &queryResult) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }
            guard status != errSecItemNotFound else { return completion(.error(.noPassword)) }
            guard status == noErr else { return completion(.error(.unhandledError(status: status))) }
            guard let existingItem = queryResult as? [String: AnyObject],
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                return completion(.error(.noPassword))
            }
            completion(.success(password))
        }
    }
    
    func save(_ password: String) throws {
        guard let encodedPassword = password.data(using: String.Encoding.utf8) else { return }
        var newItem = try KeychainPasswordItem.keychainWriteQuery(withService: service, account: account)
        newItem[kSecValueData as String] = encodedPassword as AnyObject?
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
    }
    
    func delete() throws {
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    // MARK: - Private methods
    
    private static func keychainReadQuery(withService service: String, account: String? = nil, biometricReason: String) -> [String: Any] {
        var query = keychainQuery(withService: service, account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecUseOperationPrompt as String] = biometricReason
        return query
    }
    
    private static func keychainWriteQuery(withService service: String, account: String? = nil) throws -> [String: Any] {
        var error: Unmanaged<CFError>?
        var query = keychainQuery(withService: service, account: account)
        let access: SecAccessControl?
        if #available(iOS 11.3, *) {
            access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .biometryCurrentSet, &error)
        } else {
            access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .touchIDCurrentSet, &error)
        }
        if let error = error {
            throw error.takeUnretainedValue()
        }
        query[kSecAttrAccessControl as String] = access
        return query
    }
    
    private static func keychainQuery(withService service: String, account: String? = nil) -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        if let account = account {
            query[kSecAttrAccount as String] = account
        }
        return query
    }
}

extension KeychainAuthentication: AppEventsNotifierSubscriptor {
    
    func applicationDidBecomeActive() {}
    
    func applicationWillResignActive() {
        _availableType = nil
    }
}

extension KeychainAuthentication: LocalAuthenticationPermissionsManagerProtocol {
    func enableBiometric(byKey key: String) -> BiometryEvaluationResultEntity {
        self.enableBiometric()
        return .success
    }
    
    var biometryTypeAvailable: BiometryTypeEntity {
        return findOutBiometryTypeEntity()
    }
    
    private func findOutBiometryTypeEntity() -> BiometryTypeEntity {
        var error: NSError?
        if context.canEvaluatePolicy(policy, error: &error) {
            if #available(iOS 11, *) {
                switch context.biometryType {
                case .touchID:
                    return BiometryTypeEntity.touchId
                case .faceID:
                    return BiometryTypeEntity.faceId
                case .none:
                    return BiometryTypeEntity.none
                @unknown default:
                    return BiometryTypeEntity.none
                }
            } else {
                return BiometryTypeEntity.touchId
            }
        }
        var laError: LAError?
        if let error = error {
            laError = LAError(_nsError: error)
        }
        if #available(iOS 11, *) {
            switch context.biometryType {
            case .touchID:
                return .error(biometry: BiometryTypeEntity.touchId, error: BiometryErrorEntity(laError: laError))
            case .faceID:
                return .error(biometry: BiometryTypeEntity.faceId, error: BiometryErrorEntity(laError: laError))
            case .none:
                return .error(biometry: BiometryTypeEntity.none, error: BiometryErrorEntity(laError: laError))
            @unknown default:
                return .none
            }
        }
        let hasNoBiometry = UIDevice.current.hasNoBiometry
        return .error(biometry: hasNoBiometry ? BiometryTypeEntity.none: BiometryTypeEntity.touchId, error: BiometryErrorEntity(laError: laError))
    }
    
    func evaluateBiometry(reason: String, completion: @escaping (BiometryEvaluationResultEntity) -> Void) {
        keychainPasswordItem.read(biometricReason: reason) { [weak self] result in
            switch result {
            case .success(let password):
                if password == self?.biometricPassword {
                    completion(.success)
                } else {
                    completion(.evaluationError(error: .unknown))
                }
            case .error(let error):
                switch error {
                case .noPassword:
                    completion(.evaluationError(error: .biometricOutOfDate))
                case .unexpectedItemData, .unexpectedPasswordData:
                    completion(.evaluationError(error: .unknown))
                case .unhandledError(status: let status):
                    switch status {
                    case errSecUserCanceled:
                        completion(.evaluationError(error: .userCancel))
                    default:
                        completion(.evaluationError(error: .systemCancel))
                    }
                }
            }
        }
    }
}
