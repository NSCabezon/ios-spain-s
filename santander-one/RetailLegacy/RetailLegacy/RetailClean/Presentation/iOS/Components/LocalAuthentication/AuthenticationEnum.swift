import LocalAuthentication

public enum BiometryType: Equatable {
    case touchId
    case faceId
    case none
    indirect case error(biometry: BiometryType, error: BiometryError)
    
    public static func == (lhs: BiometryType, rhs: BiometryType) -> Bool {
        switch (lhs, rhs) {
        case (.faceId, .faceId):
            return true
        case (.touchId, .touchId):
            return true
        case (.none, .none):
            return true
        case (.error(let lValue), .error(let rValue)):
            return lValue == rValue
        default:
            return false
        }
    }
}

public enum BiometryError: Error, Equatable {
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    public init(laError: LAError?) {
        switch laError?.code {
        case .biometryNotAvailable?:
            self = .biometryNotAvailable
        case .biometryLockout?:
            self = .biometryLockout
        case .biometryNotEnrolled?:
            self = .biometryNotEnrolled
        default:
            self = .unknown
        }
    }
}

public enum BiometryEvaluationResult {
    case success
    case evaluationError(error: BiometryEvaluationError)
}

public enum BiometryEvaluationError: Error {
    case appCancel
    case systemCancel
    case userCancel
    case authenticationFailed
    case biometricOutOfDate
    case unknown
    
    public init(laError: LAError?) {
        switch laError?.code {
        case .appCancel?:
            self = .appCancel
        case .systemCancel?:
            self = .systemCancel
        case .userCancel?:
            self = .userCancel
        case .authenticationFailed?:
            self = .authenticationFailed
        default:
            self = .unknown
        }
    }
}
