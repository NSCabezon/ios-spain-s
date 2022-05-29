import Foundation
import CoreFoundationLib

public final class LocalAuthenticationPermissionsManagerMock: LocalAuthenticationPermissionsManagerProtocol {
    public var biometryTypeAvailable: BiometryTypeEntity = .touchId
    public var isTouchIdEnabled: Bool = true
    public var deviceToken: String?
    public var footprint: String?

    public init() { }

    public func enableBiometric() { }

    public func enableBiometric(byKey key: String) { }

    public func evaluateBiometry(reason: String, completion: @escaping (BiometryEvaluationResultEntity) -> Void) {
        completion(.success)
    }

    public func enableBiometric(byKey key: String) -> BiometryEvaluationResultEntity {
        return .success
    }
}
