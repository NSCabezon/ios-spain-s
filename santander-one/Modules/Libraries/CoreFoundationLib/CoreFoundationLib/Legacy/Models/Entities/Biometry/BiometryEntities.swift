import LocalAuthentication

public enum BiometryTypeEntity: Equatable {
    case touchId
    case faceId
    case none
    indirect case error(biometry: BiometryTypeEntity, error: BiometryErrorEntity)
        
    static public func == (lhs: BiometryTypeEntity, rhs: BiometryTypeEntity) -> Bool {
        switch (lhs, rhs) {
        case (.faceId, .faceId):
            return true
        case (.touchId, .touchId):
            return true
        case (.none, .none):
            return true
        case (.error(let lBiometry, let lError), .error(let rBiometry, let rError)):
            return lBiometry == rBiometry && lError == rError
        default:
            return false
        }
    }
    
    public var isFaceId: Bool {
        switch self {
        case .faceId, .error(.faceId, _):
            return true
        default:
            return false
        }
    }
    
    public var isTouchId: Bool {
        switch self {
        case .touchId, .error(.touchId, _):
            return true
        default:
            return false
        }
    }
    
    public var biometryText: String {
        switch self {
        case .touchId: return "Touch ID"
        case .faceId: return "Face ID"
        default: return ""
        }
    }
}

public enum BiometryErrorEntity: Error, Equatable {
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

public enum BiometryEvaluationResultEntity {
    case success
    case evaluationError(error: BiometryEvaluationErrorEntity)
}

public enum BiometryEvaluationErrorEntity: Error {
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
