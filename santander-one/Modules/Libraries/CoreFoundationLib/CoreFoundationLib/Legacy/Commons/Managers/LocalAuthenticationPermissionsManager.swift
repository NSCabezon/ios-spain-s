
import Security
import LocalAuthentication
import UIKit.UIDevice

public protocol LocalAuthenticationPermissionsManagerProtocol: AnyObject {
    var biometryTypeAvailable: BiometryTypeEntity { get }
    var isTouchIdEnabled: Bool { get }
    var deviceToken: String? { get }
    var footprint: String? { get }
    var biometryData: Data? { get }
    func enableBiometric()
    func enableBiometric(byKey key: String) -> BiometryEvaluationResultEntity
    func evaluateBiometry(reason: String, completion: @escaping (BiometryEvaluationResultEntity) -> Void)
    func checkValidBiometry(_ oldDomainState: Data?) -> Bool
}

extension LocalAuthenticationPermissionsManagerProtocol {
    public var biometryTypeAvailable: BiometryTypeEntity {
        return findOutBiometryTypeEntity()
    }
    public var biometryData: Data? {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.evaluatedPolicyDomainState
    }
    
    public func checkValidBiometry(_ oldDomainState: Data?) -> Bool {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        guard let oldDomainState = oldDomainState,
              let domainState = context.evaluatedPolicyDomainState,
              domainState == oldDomainState
        else { return false }
        return true
    }  
}

private extension LocalAuthenticationPermissionsManagerProtocol {
    func findOutBiometryTypeEntity() -> BiometryTypeEntity {
        let context = LAContext()
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
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
}
